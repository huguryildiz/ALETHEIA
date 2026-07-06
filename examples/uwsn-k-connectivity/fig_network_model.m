clc; clear; close all;

% ------------------ Simulation Parameters ------------------
node = 30;         % Number of sensor nodes
dx = 1;            % Width of the area along x-axis (in km)
dy = 3;            % Length of the area along y-axis (in km)
dz = 0.3;          % Maximum depth along z-axis (in km)

% Define 4 possible base station positions at the corners of the area
base_positions = [ dx/2,  dy/2, 0;
                   dx/2, -dy/2, 0;
                  -dx/2,  dy/2, 0;
                  -dx/2, -dy/2, 0 ];

% ------------------ Base Station Selection ------------------
rng(42);                       % Fix random seed for reproducibility
index = randi(4);              % Randomly select one of the 4 base positions
base = base_positions(index,:);% Selected base station position

% ------------------ Sensor Node Generation ------------------
% Generate uniformly random coordinates for sensor nodes within the 3D volume
x_sensor = -dx/2 + dx * rand(1, node);
y_sensor = -dy/2 + dy * rand(1, node);
z_sensor = -dz   * rand(1, node);  % Depths are between 0 and -dz

% Combine BS and sensors into full coordinate vectors (Node 0 is BS)
x_coor = [base(1), x_sensor];
y_coor = [base(2), y_sensor];
z_coor = [base(3), z_sensor];

% Manual fine adjustments to node positions for clearer visualization
x_coor(9)  = x_coor(9)  + 0.1;
x_coor(26) = x_coor(26) - 0.1;
x_coor(28) = x_coor(28) + 0.25;
z_coor(17) = z_coor(17) + 0.1;
x_coor(17) = x_coor(17) + 0.4;
x_coor(19) = x_coor(19) + 0.2;
z_coor(19) = z_coor(19) - 0.025;
x_coor(20) = x_coor(20) + 0.4;
x_coor(21) = x_coor(21) + 0.3;
x_coor(15) = x_coor(15) + 0.1;
x_coor(22) = x_coor(22) - 0.1;
z_coor(20) = z_coor(20) - 0.025;
z_coor(16) = z_coor(16) - 0.05;
z_coor(14) = z_coor(14) - 0.05;
x_coor(30) = x_coor(30) + 0.25;
z_coor(30) = z_coor(30) - 0.025;

% ------------------ Plot Initialization ------------------
figure;
hold on; grid on; box on;

% Plot all sensor nodes (excluding BS) as black filled circles
h_sensors = scatter3(x_coor(2:end), y_coor(2:end), z_coor(2:end), 50, 'k', 'filled');

% Add node numbers as labels
for i = 2:(node+1)
    text(x_coor(i)+0.02, y_coor(i)+0.09, z_coor(i)+0.01, num2str(i-1), ...
        'FontSize', 14, 'FontName','Times New Roman', 'HorizontalAlignment', 'center');
end

% Plot all 4 base station candidates
for i = 1:4
    pos = base_positions(i, :);
    if i == index
        % Selected base station
        h_bs = scatter3(pos(1), pos(2), pos(3), 300, 'r', 'p', 'filled');
        text(pos(1)+0.02, pos(2)+0.09, pos(3)+0.01, 'BS', ...
            'FontSize', 14, 'FontName', 'Times New Roman', 'Color', 'red','HorizontalAlignment', 'center');
    else
        % Other candidate BS locations
        % h_other_bs = plot3(pos(1), pos(2), pos(3), 'rp', 'MarkerSize', 14, ...
        %      'LineWidth', 1.5, 'LineStyle', '--', 'MarkerFaceColor', 'none');
    end
end

% ------------------ Helper Function for Drawing Paths ------------------
% Plots a path and adds arrows at segment midpoints
function h_path = draw_path_with_arrows(path, x, y, z, colorSpec, lineStyle)
    h_path = plot3(x(path+1), y(path+1), z(path+1), 'Color', colorSpec, ...
                   'LineStyle', lineStyle, 'LineWidth', 1.8);

    for i = 1:length(path)-1
        x1 = x(path(i)+1); x2 = x(path(i+1)+1);
        y1 = y(path(i)+1); y2 = y(path(i+1)+1);
        z1 = z(path(i)+1); z2 = z(path(i+1)+1);
        xm = (x1 + x2)/2; ym = (y1 + y2)/2; zm = (z1 + z2)/2;

        % Draw direction arrow
        %quiver3(xm, ym, zm, (x2-x1)*0.15, (y2-y1)*0.15, (z2-z1)*0.15, ...
        %        0, 'Color', colorSpec, 'LineWidth', 1, 'MaxHeadSize', 8);
    end
end

% ------------------ Paths to Plot ------------------
% Define and draw paths from nodes to base station
h1 = draw_path_with_arrows([17, 30, 11, 12, 0], x_coor, y_coor, z_coor, 'b', '-');
h2 = draw_path_with_arrows([26, 27, 1, 0], x_coor, y_coor, z_coor, 'b', '--');
h3 = draw_path_with_arrows([26, 9, 28, 2, 7, 0], x_coor, y_coor, z_coor, 'r', '--');
h4 = draw_path_with_arrows([13, 20, 16, 0], x_coor, y_coor, z_coor, 'b', '-.');
h5 = draw_path_with_arrows([13, 3, 8, 0], x_coor, y_coor, z_coor, 'r', '-.');
h6 = draw_path_with_arrows([13, 6, 24, 19, 0], x_coor, y_coor, z_coor, 'g', '-.');

% ------------------ Anchor Lines to Seabed ------------------
%for idx = 1:length(x_coor)
%    plot3([x_coor(idx), x_coor(idx)], ...
%          [y_coor(idx), y_coor(idx)], ...
%          [z_coor(idx), -dz], ...
%          'k--', 'LineWidth', 0.5);
%end

% ------------------ Highlight Key Nodes ------------------
% Visually emphasize specific nodes
highlight_nodes = [17, 26, 13];
for i = highlight_nodes
    idx = i + 1;
    scatter3(x_coor(idx), y_coor(idx), z_coor(idx), ...
             50, 'k', 'filled');
end

% ------------------ Axes Settings ------------------
xlabel('$d_x$ (km)','Interpreter','latex');
ylabel('$d_y$ (km)','Interpreter','latex');
zlabel('$d_z$ (km)','Interpreter','latex');
set(gca, 'XTick',-dx/2:0.25:dx/2, ...
         'YTick',-dy/2:0.50:dy/2, ...
         'ZTick',-dz:0.1:0);
xlim([-dx/2, dx/2]);
ylim([-dy/2, dy/2]);
zlim([-dz, 0]);
set(gca,'FontName','Times New Roman','FontSize',16);
view(3);
ax = gca;
ax.BoxStyle = 'full';

% ------------------ Legend ------------------
% Dummy handle for BS marker to include in legend
h_bs_fake = plot3(nan, nan, nan, 'rp', 'MarkerSize', 14, 'MarkerFaceColor', 'r');
legend([h_sensors, h_bs_fake, h1, h3, h6], ...
       {'Sensor Nodes', 'BS'}, ...
       'Location', 'best');


export_fig fig_network_model -eps -transparent