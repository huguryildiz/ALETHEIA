clc; clear all; close all;

% 3 farklı veri seti için input noktaları (örnek veriler)
xi = [0.25, 0.5, 1, 2, 4]; % X ekseni (ξ)

% Her grafik için 5 noktalık epsilon (ε) değerleri
epsilon1 = [47.8, 53, 62.8, 81.4, 117.9];
epsilon2 = [50.8, 59.3, 76.6, 111.5, 182.1];
epsilon3 = [55.3, 68.4, 122, 189.3, 308.7];

% Grafik çizimi
figure;
hold all;

% Log2 ölçeğinde çizim ve dolu işaretleyiciler
semilogx(xi, epsilon1, '-ro', 'LineWidth', 1.5, 'MarkerSize', 8, 'MarkerFaceColor', 'r');
semilogx(xi, epsilon2, ':bs', 'LineWidth', 1.5, 'MarkerSize', 8,'MarkerFaceColor', 'b'); 
semilogx(xi, epsilon3, '-.kd', 'LineWidth', 1.5, 'MarkerSize', 8, 'MarkerFaceColor', 'k');

% Eksen ayarları
xlabel('$\xi$', 'Interpreter', 'latex', 'FontSize', 20);       
ylabel('$\varepsilon$ (KJ)', 'Interpreter', 'latex', 'FontSize', 20); 
set(gca, 'XScale', 'log', ...
         'XTick', [0.25 0.5 1 2 4], ...
         'XTickLabel', {'0.25', '0.5', '1', '2', '4'}, ...
         'FontName', 'Times New Roman', ...
         'FontSize', 20);

% Başka grafik ayarları
legend({'$\kappa_1=1$', '$\kappa_2=2$', '$\kappa_3=3$'}, 'Location', 'northwest','Interpreter','latex');
grid on;
box on;

%saveas(gcf,'fig_path_vareps.eps','epsc');
