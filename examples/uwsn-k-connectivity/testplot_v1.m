clc; clear; close;

% Read the CSV file into a table
df = readtable('solutions.csv');

% Create a directed graph
G = digraph();

% Extract unique nodes and map them to new positive integer IDs
nodes = unique([df.i; df.j]);
nodeMap = containers.Map(nodes, 1:numel(nodes));

% Add edges to the graph with attributes
for i = 1:height(df)
    source = df.i(i);        % Using source directly from the CSV
    destination = df.j(i);   % Using destination directly from the CSV
    k = df.k(i);
    l = df.l(i);
    value = df.val(i);
    path_label = sprintf('f_{%d,%d}^{%d,%d} = %.3f', source, destination, k, l, value);
    
    % Use the mapped node IDs for adding edges
    G = addedge(G, nodeMap(source), nodeMap(destination), value);
    
    % Store edge labels and additional attributes in custom properties
    G.Edges.Label(i) = {path_label};
    G.Edges.k_value(i) = k;
    G.Edges.l_value(i) = l;
end

% Define node positions based on the given coordinates
positions = [
    -0.5, 0;
    -0.4084, -0.1389;
    -0.3309, 0.30896;
    0.35383, -0.24842;
    -0.28778, -0.46427;
    0.18125, 0.49972;
    0.13847, 0.30367;
    0.36024, 0.00907;
    -0.12794, 0.43571;
    0.00207, 0.40121;
    0.37103, -0.13599;
    0.43185, 0.40775;
    -0.07639, 0.38406
];

% Plot the network
figure('Position', [100, 100, 800, 600]);
hold on;

% Create a cell array of character vectors for the node labels (0 to 12)
nodeLabels = arrayfun(@num2str, 0:12, 'UniformOutput', false);

% Assign the labels to the graph nodes
G.Nodes.Name = nodeLabels';

% Define edge color and linestyle based on k and l values
edge_colors = cell(height(G.Edges), 1);
edge_styles = cell(height(G.Edges), 1);

% Prepare edge labels
edgeLabels = cell(height(G.Edges), 1);

highlightEdges = false(1, height(G.Edges));  % Initialize logical array

for i = 1:height(G.Edges)
    k = G.Edges.k_value(i);
    l = G.Edges.l_value(i);
    edgeLabels{i} = G.Edges.Label{i}; 
    
    if k == 3 && l == 1
        edge_colors{i} = 'b';  % Blue for (k=3, l=1)
        edge_styles{i} = '-';  % Solid line
        highlightEdges(i) = true;  % Mark edges to be highlighted
    elseif k == 3 && l == 2
        edge_colors{i} = 'r';  % Red for (k=3, l=2)
        edge_styles{i} = '-';  % Solid line
        highlightEdges(i) = true;  % Mark edges to be highlighted
    elseif k == 3 && l == 3
        edge_colors{i} = 'g';  % Green for (k=3, l=3)
        edge_styles{i} = '-';  % Solid line
        highlightEdges(i) = true;  % Mark edges to be highlighted
    else
        edge_colors{i} = [0.8 0.8 0.8];  % Grey for k != 3
        edge_styles{i} = ':';  % Dashed line for k != 3
    end
end

% Draw edges with curved arrows and dynamic styles
curvedEdgePlot = plot(G, 'XData', positions(:, 1), 'YData', positions(:, 2), ...
                          'LineWidth', 1, 'LineStyle', ':',...
                          'EdgeColor', [0.8 0.8 0.8],...
                          'ArrowSize', 10,'NodeColor','b','MarkerSize',10);

% Set edge labels
%set(curvedEdgePlot,'EdgeLabel',edgeLabels)


% Apply specific colors and styles to edges of interest
for i = find(highlightEdges)
    disp(i)
    highlight(curvedEdgePlot, 'Edges', i, 'EdgeColor', edge_colors{i}, ...
             'LineStyle', edge_styles{i}, 'LineWidth', 1.5);
    if G.Edges.k_value(i) == 3 && G.Edges.l_value(i) == 1
        % Label this specific edge with its edge label
        disp([i G.Edges.EndNodes(i, 1) G.Edges.EndNodes(i, 2) edgeLabels{i}])
        labeledge(curvedEdgePlot, G.Edges.EndNodes(i, 1), G.Edges.EndNodes(i, 2), edgeLabels{i});
    end
    
    if G.Edges.k_value(i) == 3 && G.Edges.l_value(i) == 2
        % Label this specific edge with its edge label
        labeledge(curvedEdgePlot, G.Edges.EndNodes(i, 1), G.Edges.EndNodes(i, 2), edgeLabels{i});
    end

    if G.Edges.k_value(i) == 3 && G.Edges.l_value(i) == 3
        % Label this specific edge with its edge label
        labeledge(curvedEdgePlot, G.Edges.EndNodes(i, 1), G.Edges.EndNodes(i, 2), edgeLabels{i});
    end
end


% Remove axis

axis off;

% Save the plot as a PNG
saveas(gcf, 'network_plot.png');
hold off;
