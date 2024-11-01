require 'set'

class KnightTravails
  attr_accessor :distances_from_source, :visited, :source, :neighbors, :path, :unexplored_neighbors, :found

  EDGE_WEIGHT = 3

  def initialize
    @visited = Set.new
    @distances_from_source = {}
    @source = nil
    @path = []
    @found = false
  end

  def find_neighbor(vertex)
    @neighbors = []
    vertical = Array.new(2)
    horizontal = Array.new(2)

    [2, -2].each do |x|
      vertical[0] = x + vertex[0]
      [1, -1].each do |y|
        vertical[1] = y + vertex[1]
        @neighbors << vertical.dup if vertical[0].between?(0, 7) &&
                                      vertical[1].between?(0, 7) &&
                                      !@visited.include?(vertical)
      end
    end

    [1, -1].each do |x|
      horizontal[0] = x + vertex[0]
      [2, -2].each do |y|
        horizontal[1] = y + vertex[1]
        @neighbors << horizontal.dup if horizontal[0].between?(0, 7) &&
                                        horizontal[1].between?(0, 7) &&
                                        !@visited.include?(horizontal)
      end
    end

    calculate_distance(@neighbors)
    @neighbors
  end

  def calculate_distance(neighbors)
    neighbors.each do |vertex|
      next if @distances_from_source.include?(vertex)

      @distances_from_source[vertex] =
        { shortest_dist: Float::INFINITY, previous_vertex: nil }
    end
  end

  def relaxation(current, neighbor)
    distance = @distances_from_source[current][:shortest_dist] + EDGE_WEIGHT
    return unless distance < @distances_from_source[neighbor][:shortest_dist]

    @distances_from_source[neighbor][:shortest_dist] = distance
    @distances_from_source[neighbor][:previous_vertex] = current
  end

  def find_lowest_dist(target)
    lowest = @unexplored_neighbors.min_by { |_, value| value[:shortest_dist] }&.first

    if @unexplored_neighbors.key?(target) && @distances_from_source[target][:shortest_dist] <= (lowest ? @distances_from_source[lowest][:shortest_dist] : Float::INFINITY)
      @found = true
      target
    else
      lowest
    end
  end

  def trace_back(destination)
    return @path if destination.nil?

    @path.unshift(destination)
    trace_back(@distances_from_source[destination][:previous_vertex])
  end

  def knight_moves(source, destination)
    unless source.all? { |coord| coord.between?(0, 7) } && destination.all? { |coord| coord.between?(0, 7) }
      return 'Invalid source or destination'
    end

    @distances_from_source[source] = { shortest_dist: 0, previous_vertex: nil }
    @source = source

    loop do
      @unexplored_neighbors = @distances_from_source.reject { |vertex, _| @visited.include?(vertex) }

      current_vertex = find_lowest_dist(destination)
      break if current_vertex.nil? || @found

      @visited.add(current_vertex)

      find_neighbor(current_vertex)
      @neighbors.each do |neighbor|
        relaxation(current_vertex, neighbor)
      end
    end

    if @found
      trace_back(destination)
      puts "You made it in #{@path.length} moves! Here's your path:"
      @path.each do |vertex|
        p vertex
      end
    else
      puts 'No path found'
    end
  end
end
