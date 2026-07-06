clc;
clear all;
close all;

% 3 farklı veri seti için input noktaları (örnek veriler)
xi = [0.25, 0.5, 1, 2, 4]; % X ekseni (ξ)

% Her grafik için 5 noktalık epsilon (ε) değerleri
epsilon1 = [47.8, 53, 62.8, 81.4, 117.9];
epsilon2 = [50.8, 59.3, 76.6, 111.5, 182.1];
epsilon3 = [55.3, 68.4, 122, 189.3, 308.7];

% Grafik çizimi
figure;
hold all;
plot(xi, epsilon1, '-ro', 'LineWidth', 1.5);
plot(xi, epsilon2, ':bs', 'LineWidth', 1.5); 
plot(xi, epsilon3, '-.kd', 'LineWidth', 1.5);

% Eksen adları
xlabel('$\xi$', 'Interpreter', 'latex', 'FontSize', 20);       
ylabel('$\varepsilon$', 'Interpreter', 'latex', 'FontSize', 20); 
set(gca,'XTick', [0.25 0.5 1 2 4],'FontName','Times New Roman','Fontsize', 20)

% Başka grafik ayarları
legend({'1', '2', '3'}, 'Location', 'northwest');
grid on;
box on;