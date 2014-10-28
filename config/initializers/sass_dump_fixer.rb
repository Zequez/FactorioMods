require 'sass'

module Sass
  module Tree
    class ImportNode < RootNode
      def _dump(f)
        Marshal.dump([@imported_filename, children])
      end

      def self._load(data)
        filename, children = Marshal.load(data)
        node = ImportNode.new(filename)
        node.children = children
        node
      end
    end
  end
end