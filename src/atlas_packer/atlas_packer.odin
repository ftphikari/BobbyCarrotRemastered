package atlas_packer

import "core:runtime"

Node :: struct {
	child: [2]^Node,
	pos: [2]uint,
	size: [2]uint,
	full: bool,
}

Atlas :: struct {
	allocator: runtime.Allocator,
	root_node: ^Node,
}

init :: proc(atlas: ^Atlas, size: [2]uint, allocator := context.allocator) {
	atlas.allocator = allocator
	atlas.root_node = new(Node, atlas.allocator)
	atlas.root_node.pos = {}
	atlas.root_node.size = size
}

destroy :: proc(atlas: ^Atlas) {
	if atlas.root_node != nil {
		_delete_node(atlas.root_node, atlas.allocator)
	}

	atlas^ = {}
}

try_insert :: proc(atlas: ^Atlas, size: [2]uint) -> (pos: [2]uint, ok: bool) {
	node := _insert_node(atlas.root_node, size, atlas.allocator)
	if node == nil {
		return
	}
	return node.pos, true
}

_insert_node :: proc(node: ^Node, size: [2]uint, allocator: runtime.Allocator) -> ^Node {
	if node.full {
		if node.child[0] != nil {
			n := _insert_node(node.child[0], size, allocator)
			if n != nil {
				return n
			}
		}

		if node.child[1] != nil {
			n := _insert_node(node.child[1], size, allocator)
			if n != nil {
				return n
			}
		}

		return nil
	}

	if size[0] > node.size[0] || size[1] > node.size[1] {
		return nil
	}
	node.full = true

	if size[0] < node.size[0] {
		node.child[0] = new(Node, allocator)
	}
	if size[1] < node.size[1] {
		node.child[1] = new(Node, allocator)
	}

	if node.child[0] != nil && node.child[1] != nil {
		node.child[0].pos = {node.pos.x + size[0], node.pos.y}
		node.child[0].size[0] = node.size[0] - size[0]
		node.child[1].pos = {node.pos.x, node.pos.y + size[1]}
		node.child[1].size[1] = node.size[1] - size[1]

		if size[0] > size[1] {
			node.child[0].size[1] = node.size[1]
			node.child[1].size[0] = size[0]
		} else {
			node.child[0].size[1] = size[1]
			node.child[1].size[0] = node.size[0]
		}
	} else if node.child[0] != nil && node.child[1] == nil {
		node.child[0].pos = {node.pos.x + size[0], node.pos.y}
		node.child[0].size = {node.size[0] - size[0], node.size[1]}
	} else if node.child[0] == nil && node.child[1] != nil {
		node.child[1].pos = {node.pos.x, node.pos.y + size[1]}
		node.child[1].size = {node.size[0], node.size[1] - size[1]}
	}

	return node
}

// recursively deletes the node and every node inside it
_delete_node :: proc(node: ^Node, allocator: runtime.Allocator) {
	if node.child[0] != nil {
		_delete_node(node.child[0], allocator)
	}
	if node.child[1] != nil {
		_delete_node(node.child[1], allocator)
	}

	free(node, allocator)
}
