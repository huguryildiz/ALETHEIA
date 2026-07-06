clc; clear; close;

% eksenler km
% 9 figürde ortak energy colorbar yaratmak lazım.

% Read the CSV file into a table
df = readtable('solutions_k1_k3.csv');

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

% The amount energy dissipated by the nodes
energies = 1e-3 * [
    0;
    10523.49971909;
    12665.11234544;
    12839.58100134;
    11391.08911778;
    11748.97971321;
    12840.01926029;
    12837.7214773;
    11623.6806366;
    12696.77201346;
    12840.80053085;
    5512.93388418;
    12365.29780554
];

% Exclude node 0 from the color mapping
node_energies = energies(2:end);

% Normalize energy values to be between 0 and 1
normalized_energies = (node_energies - min(node_energies)) / (max(node_energies) - min(node_energies));

% Use the 'jet' colormap for node coloring
num_nodes = length(normalized_energies);
colormap_jet = jet(num_nodes);  % Create the colormap with the same length as the number of nodes

% Create a 256-level 'jet' colormap
colormap_jet = jet(256);

% Map the normalized energies to the colormap
% Interpolate normalized values to get colors from the colormap
node_colors = interp1(linspace(0, 1, 256), colormap_jet, normalized_energies);

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
    elseif k == 15 && l == 1
        edge_colors{i} = 'b';  % Blue for (k=*5, l=1)
        edge_styles{i} = '-';  % Solid line
        highlightEdges(i) = true;  % Mark edges to be highlighted
     elseif k == 15 && l == 2
        edge_colors{i} = 'r';  % Red for (k=*5, l=2)
        edge_styles{i} = '-';  % Solid line
        highlightEdges(i) = true;  % Mark edges to be highlighted
     elseif k == 15 && l == 3
        edge_colors{i} = 'g';  % Green for (k=*5, l=3)
        edge_styles{i} = '-';  % Solid line
        highlightEdges(i) = true;  % Mark edges to be highlighted       
    elseif k == 12 && l == 1
        edge_colors{i} = 'b';  % Blue for (k=12, l=1)
        edge_styles{i} = '-';  % Solid line
        highlightEdges(i) = true;  % Mark edges to be highlighted
    elseif k == 12 && l == 2
        edge_colors{i} = 'r';  % Red for (k=12, l=2)
        edge_styles{i} = '-';  % Solid line
        highlightEdges(i) = true;  % Mark edges to be highlighted
    elseif k == 12 && l == 3
        edge_colors{i} = 'g';  % Green for (k=12, l=3)
        edge_styles{i} = '-';  % Solid line
        highlightEdges(i) = true;  % Mark edges to be highlighted   
    else
        edge_colors{i} = [0.5 0.5 0.5];  % Grey for k != 3
        edge_styles{i} = ':';  % Dashed line for k != 3
    end
end

% Draw edges with default grey and dashed style
curvedEdgePlot = plot(G, 'XData', positions(:, 1), 'YData', positions(:, 2), ...
                          'LineWidth', 1, 'LineStyle', ':',...
                          'EdgeColor', [0.5 0.5 0.5],...
                          'ArrowSize', 10, 'MarkerSize', 14,...
                          'NodeFontWeight','bold',...
                          'NodeFontSize',11);

% Highlight and label only specific edges where k == 3 and l == 1
for i = find(highlightEdges)
    highlight(curvedEdgePlot, 'Edges', i, 'EdgeColor', edge_colors{i}, ...
             'LineStyle', edge_styles{i}, 'LineWidth', 1.5,...
             'EdgeFontSize',10,'EdgeFontWeight','bold');

    labeledge(curvedEdgePlot, i, edgeLabels{i});
end

% Define the node markers
nodeMarkers = repmat({'o'}, numel(G.Nodes.Name), 1);  % Default marker: circle
nodeMarkers{1} = 'pentagram';  % Use pentagram for node 1

% Color the nodes according to their energy values
for i = 1:length(nodeLabels)
    if i == 1
        highlight(curvedEdgePlot, i, 'NodeColor', 'k');
    else
        highlight(curvedEdgePlot, i, 'NodeColor', node_colors(i-1, :));
    end
end

% Apply square marker for node 1 and circle for the others
for i = 1:numel(G.Nodes.Name)
    if strcmp(nodeMarkers{i}, 'pentagram')  % Square marker for node 1
        highlight(curvedEdgePlot, i, 'Marker', 'pentagram', 'MarkerSize', 18);
    else  % Circle marker for other nodes
        highlight(curvedEdgePlot, i, 'Marker', 'o');
    end
end

% Add colorbar to represent the node energy levels
colormap(colormap_jet);
c = colorbar;
c.Label.String = 'Energy Dissipation (KJ)';
c.Label.FontSize = 14;
caxis([round(min(node_energies)) ceil(max(node_energies))]);  % Set color axis to match the energy range

% Create custom legend using dummy plot handles
h_blue = plot(nan, nan, 'b-', 'LineWidth', 1.5);   % Blue solid line for l=1
h_red = plot(nan, nan, 'r-', 'LineWidth', 1.5);    % Red solid line for l=2
h_green = plot(nan, nan, 'g-', 'LineWidth', 1.5);  % Green solid line for l=3

% Add the legend
legend([h_blue, h_red, h_green], {'$l = 1$', '$l = 2$', '$l = 3$'}, ...
    'FontSize',18, 'Location', 'NorthWest','Interpreter','latex');

% Set plot properties
%set(curvedEdgePlot,'FontSize',14)
grid on;
xlim([-0.5 0.5]);
ylim([-0.5 0.5]);
box on;

set(gca,'FontSize',14)
title('\tau = 12.84 KJ')
% Save the plot as a PNG
saveas(gcf, 'network_plot_k1_k3.png');
hold off;
