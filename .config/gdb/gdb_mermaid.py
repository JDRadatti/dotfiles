#!/usr/bin/env python3
"""
gdb_mermaid.py

A generic GDB command that visualizes a variable, pointer, or expression as a
Mermaid diagram and writes it to the current working directory.

Install:
    mkdir -p ~/.config/gdb
    cp gdb_mermaid.py ~/.config/gdb/
    echo "source ~/.config/gdb/gdb_mermaid.py" >> ~/.gdbinit

Usage (inside GDB):
    mermaid <expression> [--depth N] [--max-children M] [--pointer-buffer-bytes B]
                         [--no-follow-pointers] [--inline-primitives] [--output file.mmd]

Examples:
    mermaid my_struct
    mermaid *my_ptr --depth 8
    mermaid my_array --no-follow-pointers --max-children 10
    mermaid my_vec --pointer-buffer-bytes 32
"""

import gdb
import os
import re
from datetime import datetime


# ---------------------------------------------------------------------------
# Data model
# ---------------------------------------------------------------------------

class MermaidNode:
    def __init__(self, node_id, label, shape="box"):
        self.node_id = node_id
        self.label = label
        self.shape = shape


class MermaidEdge:
    def __init__(self, from_id, to_id, label="", dotted=False):
        self.from_id = from_id
        self.to_id = to_id
        self.label = label
        self.dotted = dotted


class MermaidDiagram:
    def __init__(self):
        self.nodes = {}
        self.edges = []
        self._counter = 0

    def new_id(self):
        self._counter += 1
        return "n{}".format(self._counter)

    def add_node(self, node_id, label, shape="box"):
        if node_id not in self.nodes:
            self.nodes[node_id] = MermaidNode(node_id, label, shape)
        return node_id

    def add_edge(self, from_id, to_id, label="", dotted=False):
        self.edges.append(MermaidEdge(from_id, to_id, label, dotted))

    def render(self):
        lines = ["graph TD"]
        for node in self.nodes.values():
            escaped = escape_label(node.label)
            if node.shape == "diamond":
                lines.append('  {}{{"{}"}}'.format(node.node_id, escaped))
            elif node.shape == "round":
                lines.append('  {}(("{}"))'.format(node.node_id, escaped))
            else:
                lines.append('  {}["{}"]'.format(node.node_id, escaped))
        for edge in self.edges:
            style = "-.->" if edge.dotted else "-->"
            label_part = '|"{}"|'.format(escape_label(edge.label)) if edge.label else ""
            lines.append('  {} {} {} {}'.format(edge.from_id, style, label_part, edge.to_id))
        return "\n".join(lines) + "\n"


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def escape_label(s):
    # Escape backslashes first, then special whitespace, then quotes.
    s = str(s).replace("\\", "\\\\").replace("\n", "\\n").replace("\r", "\\r").replace('"', '\\"')
    if len(s) > 200:
        s = s[:197] + "..."
    return s


def get_type_name(t):
    name = t.name or t.tag
    if name:
        return name
    return str(t)


def is_null_pointer(value):
    try:
        return int(value) == 0
    except Exception:
        return False


def pointer_address(value):
    """Return the integer address stored in a pointer value, or None."""
    try:
        addr = int(value)
        return addr if addr != 0 else None
    except Exception:
        return None


def type_size_str(t):
    """Return ' (N)' with the type's size, or ' (?)' if unknown."""
    try:
        return " ({})".format(t.sizeof)
    except Exception:
        return " (?)"


def is_byte_like_type(t):
    """True for byte/char types that are worth previewing as a buffer."""
    name = get_type_name(t).lower()
    return name in ("u8", "i8", "char", "unsigned char", "signed char",
                    "byte", "std::byte")


def format_byte_preview(data):
    """Format a bytes-like object as 'hex... (ascii...)'."""
    hex_part = " ".join("{:02x}".format(b) for b in data)
    ascii_part = "".join(chr(b) if 32 <= b < 127 else "." for b in data)
    return "{} ('{}')".format(hex_part, ascii_part)


def read_byte_buffer_preview(addr, max_bytes):
    """Read up to max_bytes from addr and return a preview string, or None."""
    if max_bytes <= 0 or addr is None:
        return None
    try:
        data = gdb.selected_inferior().read_memory(addr, max_bytes).tobytes()
        if not data:
            return None
        return format_byte_preview(data)
    except Exception:
        return None


def value_address(value):
    """Return the memory address where this value lives, or None."""
    try:
        addr = value.address
        if addr is not None:
            return int(addr)
    except Exception:
        pass
    return None


def node_id_for_value(value, allow_address=True):
    """Choose a stable node id based on the value's memory address."""
    if not allow_address:
        return None
    addr = value_address(value)
    if addr is not None and addr != 0:
        return "n0x{:x}".format(addr)
    return None


# ---------------------------------------------------------------------------
# Traversal
# ---------------------------------------------------------------------------

COMPLEX_TYPE_CODES = {
    gdb.TYPE_CODE_PTR,
    gdb.TYPE_CODE_REF,
    gdb.TYPE_CODE_STRUCT,
    gdb.TYPE_CODE_UNION,
    gdb.TYPE_CODE_ARRAY,
    gdb.TYPE_CODE_ENUM,
}


def traverse_value(value, diagram, depth, max_depth, follow_pointers,
                   max_children, visited, allow_address=True,
                   inline_primitives=False, buffer_bytes=16):
    """
    Recursively inspect a gdb.Value and add nodes/edges to the diagram.
    Returns the node id for this value.
    """
    the_type = value.type.strip_typedefs()
    type_code = the_type.code

    # Try to reuse existing nodes for memory-backed values to prevent cycles.
    addr_id = node_id_for_value(value, allow_address)
    if addr_id is not None and type_code in COMPLEX_TYPE_CODES:
        if addr_id in visited:
            return addr_id
        visited.add(addr_id)

    if depth > max_depth:
        nid = addr_id or diagram.new_id()
        diagram.add_node(nid, "{} <max depth>{}".format(
            get_type_name(the_type), type_size_str(the_type)))
        return nid

    # Pointers ---------------------------------------------------------------
    if type_code == gdb.TYPE_CODE_PTR:
        nid = addr_id or diagram.new_id()
        addr = pointer_address(value)
        type_name = get_type_name(value.type)
        pointee_type = value.type.target().strip_typedefs()
        size_suffix = type_size_str(value.type)

        if is_null_pointer(value):
            diagram.add_node(nid, "{}: NULL{}".format(type_name, size_suffix))
        elif not follow_pointers:
            diagram.add_node(nid, "{}: 0x{:x}{}".format(type_name, addr or 0, size_suffix))
        elif addr is None:
            diagram.add_node(nid, "{}: <invalid>{}".format(type_name, size_suffix))
        else:
            # Try a byte-buffer preview before generic dereference.
            preview = None
            if buffer_bytes > 0 and is_byte_like_type(pointee_type):
                preview = read_byte_buffer_preview(addr, buffer_bytes)

            if preview is not None:
                buffer_id = diagram.new_id()
                buffer_label = "{} buffer{}: {}".format(
                    get_type_name(pointee_type), type_size_str(pointee_type), preview)
                diagram.add_node(buffer_id, buffer_label)
                diagram.add_node(nid, "{}: 0x{:x}{}".format(type_name, addr, size_suffix))
                diagram.add_edge(nid, buffer_id, "*", dotted=True)
            else:
                try:
                    pointee = value.dereference()
                    pointee_id = traverse_value(pointee, diagram, depth + 1,
                                                max_depth, follow_pointers,
                                                max_children, visited,
                                                inline_primitives=inline_primitives,
                                                buffer_bytes=buffer_bytes)
                    diagram.add_node(nid, "{}: 0x{:x}{}".format(type_name, addr, size_suffix))
                    diagram.add_edge(nid, pointee_id, "*", dotted=True)
                except Exception as e:
                    diagram.add_node(nid, "{}: 0x{:x} <deref error: {}>{}".format(
                        type_name, addr, str(e), size_suffix))
        return nid

    # References -------------------------------------------------------------
    if type_code == gdb.TYPE_CODE_REF:
        nid = addr_id or diagram.new_id()
        try:
            ref_val = value.referenced_value()
            ref_id = traverse_value(ref_val, diagram, depth + 1, max_depth,
                                    follow_pointers, max_children, visited,
                                    inline_primitives=inline_primitives,
                                    buffer_bytes=buffer_bytes)
            ref_addr = value_address(ref_val)
            label = "{}: 0x{:x}{}".format(
                get_type_name(value.type), ref_addr or 0, type_size_str(value.type))
            diagram.add_node(nid, label)
            diagram.add_edge(nid, ref_id, "&", dotted=True)
        except Exception as e:
            diagram.add_node(nid, "{} <ref error: {}>{}".format(
                get_type_name(value.type), str(e), type_size_str(value.type)))
        return nid

    # Arrays -----------------------------------------------------------------
    if type_code == gdb.TYPE_CODE_ARRAY:
        nid = addr_id or diagram.new_id()
        try:
            low, high = the_type.range()
            length = high - low + 1
        except Exception:
            length = 0

        diagram.add_node(nid, "{}[{}]{}".format(
            get_type_name(the_type), length, type_size_str(the_type)))
        count = min(length, max_children)
        for i in range(count):
            try:
                elem = value[i + low]
                # Array elements are not independently shareable objects;
                # use synthetic ids so the array node does not collapse into
                # its first element (which has the same address as the array).
                elem_id = traverse_value(elem, diagram, depth + 1, max_depth,
                                         follow_pointers, max_children, visited,
                                         allow_address=False,
                                         inline_primitives=inline_primitives,
                                         buffer_bytes=buffer_bytes)
                diagram.add_edge(nid, elem_id, "[{}]".format(i + low))
            except Exception as e:
                err_id = diagram.new_id()
                diagram.add_node(err_id, "<error: {}>".format(str(e)))
                diagram.add_edge(nid, err_id, "[{}]".format(i + low))
        if length > max_children:
            more_id = diagram.new_id()
            diagram.add_node(more_id, "... {} more".format(length - max_children))
            diagram.add_edge(nid, more_id)
        return nid

    # Structs / Unions -------------------------------------------------------
    if type_code in (gdb.TYPE_CODE_STRUCT, gdb.TYPE_CODE_UNION):
        nid = addr_id or diagram.new_id()
        try:
            fields = list(the_type.fields())
        except Exception:
            fields = []

        inlined = []
        child_edges = []
        count = min(len(fields), max_children)

        for i, field in enumerate(fields[:count]):
            field_name = field.name or "<anon{}>".format(i)
            try:
                field_val = value[field]
                field_type = field_val.type.strip_typedefs()
                if inline_primitives and field_type.code not in COMPLEX_TYPE_CODES:
                    inlined.append("{}: {}".format(field_name, field_val))
                else:
                    # Fields share the address of the containing object (at
                    # offset 0), so use synthetic ids to avoid collapsing the
                    # first field into its parent.
                    child_id = traverse_value(field_val, diagram, depth + 1,
                                              max_depth, follow_pointers,
                                              max_children, visited,
                                              allow_address=False,
                                              inline_primitives=inline_primitives,
                                              buffer_bytes=buffer_bytes)
                    child_edges.append((nid, child_id, field_name))
            except Exception as e:
                inlined.append("{}: <error: {}>".format(field_name, str(e)))

        if len(fields) > max_children:
            inlined.append("... {} more fields".format(len(fields) - max_children))

        type_name = get_type_name(the_type)
        if inlined:
            body = "{}\\n{}".format(type_name, "\\n".join(inlined))
        else:
            body = type_name
        diagram.add_node(nid, "{}{}".format(body, type_size_str(the_type)))

        for from_id, to_id, label in child_edges:
            diagram.add_edge(from_id, to_id, label)
        return nid

    # Enums ------------------------------------------------------------------
    if type_code == gdb.TYPE_CODE_ENUM:
        nid = addr_id or diagram.new_id()
        try:
            label = "{}\\n= {}{}".format(
                get_type_name(the_type), value, type_size_str(the_type))
        except Exception:
            label = "{}{}".format(get_type_name(the_type), type_size_str(the_type))
        diagram.add_node(nid, label, shape="diamond")
        return nid

    # Everything else (primitives, functions, etc.) --------------------------
    nid = addr_id or diagram.new_id()
    try:
        val_str = str(value)
    except Exception:
        val_str = "<unable to read>"
    label = "{}: {}{}".format(
        get_type_name(the_type), val_str, type_size_str(the_type))
    diagram.add_node(nid, label, shape="round")
    return nid


# ---------------------------------------------------------------------------
# GDB command
# ---------------------------------------------------------------------------

class MermaidCommand(gdb.Command):
    """
    mermaid <expression> [--depth N] [--max-children M] [--pointer-buffer-bytes B]
                         [--no-follow-pointers] [--inline-primitives] [--output file.mmd]
    """

    def __init__(self):
        super().__init__("mermaid", gdb.COMMAND_DATA, gdb.COMPLETE_EXPRESSION)

    def invoke(self, arg, from_tty):
        args = self.parse_args(arg)
        expr = args.get("expr")
        if not expr:
            print("Usage: mermaid <expression> [--depth N] [--max-children M] "
                  "[--pointer-buffer-bytes B] [--no-follow-pointers] "
                  "[--inline-primitives] [--output file.mmd]")
            return

        try:
            depth = int(args.get("depth", 6))
            max_children = int(args.get("max-children", 32))
            buffer_bytes = int(args.get("pointer-buffer-bytes", 16))
        except ValueError:
            print("Error: --depth, --max-children, and --pointer-buffer-bytes "
                  "must be integers")
            return

        follow_pointers = not args.get("no-follow-pointers", False)
        inline_primitives = args.get("inline-primitives", False)
        output = args.get("output")

        try:
            value = gdb.parse_and_eval(expr)
        except Exception as e:
            print("Error evaluating '{}': {}".format(expr, str(e)))
            return

        diagram = MermaidDiagram()
        visited = set()
        traverse_value(value, diagram, 0, depth, follow_pointers,
                       max_children, visited,
                       inline_primitives=inline_primitives,
                       buffer_bytes=buffer_bytes)

        mermaid_text = diagram.render()

        if not output:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            safe_expr = re.sub(r"[^\w]", "_", expr)[:40].strip("_") or "expr"
            output = "{}_{}.mmd".format(safe_expr, timestamp)

        output_path = os.path.abspath(output)
        try:
            with open(output_path, "w") as f:
                f.write(mermaid_text)
            print("Mermaid diagram written to: {}".format(output_path))
            print("Nodes: {}, Edges: {}".format(len(diagram.nodes), len(diagram.edges)))
        except Exception as e:
            print("Error writing '{}': {}".format(output_path, str(e)))

    def parse_args(self, arg):
        tokens = gdb.string_to_argv(arg)
        result = {}
        i = 0
        while i < len(tokens):
            token = tokens[i]
            if token == "--depth" and i + 1 < len(tokens):
                result["depth"] = tokens[i + 1]
                i += 2
            elif token == "--max-children" and i + 1 < len(tokens):
                result["max-children"] = tokens[i + 1]
                i += 2
            elif token == "--output" and i + 1 < len(tokens):
                result["output"] = tokens[i + 1]
                i += 2
            elif token == "--pointer-buffer-bytes" and i + 1 < len(tokens):
                result["pointer-buffer-bytes"] = tokens[i + 1]
                i += 2
            elif token == "--no-follow-pointers":
                result["no-follow-pointers"] = True
                i += 1
            elif token == "--inline-primitives":
                result["inline-primitives"] = True
                i += 1
            else:
                if "expr" not in result:
                    result["expr"] = token
                else:
                    result["expr"] += " " + token
                i += 1
        return result


MermaidCommand()
print("Loaded gdb_mermaid.py — use: mermaid <expression>")
