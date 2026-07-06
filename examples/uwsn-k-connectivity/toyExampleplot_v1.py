import pandas as pd
import networkx as nx
import matplotlib.pyplot as plt

# Read CSV into a pandas DataFrame
df = pd.read_csv('solutions.csv')

# Create a directed graph
G = nx.DiGraph()

# Add edges to the graph
for _, row in df.iterrows():
    source = row['i']
    destination = row['j']
    k = row['k']
    l = row['l']
    value = row['val']
    path_label = r"$f_{{{:.0f},{:.0f}}}^{{{:.0f},{:.0f}}} = {:.3f}$".format(source, destination, k, l, value)

    # Add edge with the label, k, and l values as edge attributes
    G.add_edge(source, destination, weight=value, label=path_label, k_value=k, l_value=l)

# Manually define the node positions based on the given coordinates
positions = {
    0: (-0.5, 0),
    1: (-0.4084152125949264, -0.1389425260163928),
    2: (-0.3309163843395563, 0.30896204463936683),
    3: (0.35383438548547363, -0.24841670240503433),
    4: (-0.2877811893313994, -0.4642655582636296),
    5: (0.18124618499266254, 0.49971879594526913),
    6: (0.1384713381046937, 0.30366944315293487),
    7: (0.3602441027374532, 0.009067453066970876),
    8: (-0.12793970447646796, 0.4357116851572259),
    9: (0.002067292245035879, 0.401207797496947),
    10: (0.3710329683679704, -0.13598557215263063),
    11: (0.4318465539698684, 0.40775011017929697),
    12: (-0.07638903042830936, 0.3840645665358958)
}

# Plot the network
plt.figure(figsize=(12, 8))

# Define color and linestyle mapping based on k and l values
edge_colors = []
edge_styles = []
for (u, v, d) in G.edges(data=True):
    k = d['k_value']
    l = d['l_value']

    if k == 3 and l == 1:
        edge_colors.append('blue')  # Blue for (k=3, l=1)
        edge_styles.append('solid')  # Solid line
    elif k == 3 and l == 2:
        edge_colors.append('red')  # Red for (k=3, l=2)
        edge_styles.append('solid')  # Solid line
    elif k == 3 and l == 3:
        edge_colors.append('green')  # Green for (k=3, l=3)
        edge_styles.append('solid')  # Solid line
    else:
        edge_colors.append('grey')  # Grey for k != 3
        edge_styles.append('dashed')  # Dashed line for k != 3

# Draw the nodes
nx.draw_networkx_nodes(G, positions, node_color='lightblue', node_size=500)

# Create labels with 0 decimal digits
node_labels = {node: f'{node:.0f}' for node in G.nodes()}

# Draw edges with curved arrows and dynamic edge styles
for (u, v, d), edge_color, style in zip(G.edges(data=True), edge_colors, edge_styles):
    nx.draw_networkx_edges(
        G, positions, edgelist=[(u, v)], arrowstyle='-|>', arrowsize=8,
        edge_color=edge_color, style=style, connectionstyle='arc3,rad=0.05'
    )

# Draw labels for the nodes
nx.draw_networkx_labels(G, positions, labels=node_labels, font_size=10, font_color='black')

# Annotate edges with path info and dynamic font color
edge_labels = nx.get_edge_attributes(G, 'label')
for (u, v, d) in G.edges(data=True):
    edge_label = edge_labels[(u, v)]

    # Use black font color for edge labels
    font_color = 'black'

    # Draw edge label with dynamic font color and transparent background
    nx.draw_networkx_edge_labels(
        G,
        positions,
        edge_labels={(u, v): edge_label},
        font_size=8,  # Use 8 font size for edge labels
        font_color=font_color,
        label_pos=0.9,
        bbox=dict(facecolor='none', edgecolor='none')  # Transparent background
    )

plt.axis('off')
plt.savefig("network_plot.png", dpi=300, format='png')
plt.show()
