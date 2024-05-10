% Autor: Guillermo Fernando Regodón Harkness
% Github: https://github.com/GuillermoRegodon/matlab-class-smithchart.git

% Clase de Matlab para crear objetos para practicar el uso de la carta de
% Smith en su aplicación a líneas de transmisión.

% Los objetos son una estructura de datos más las funciones permitidas.
% En Matlab, significa que tenemos que devolver siempre la estructura y
% guardarla. Si no, la computación se pierde (aunque otros efectos, como 
% plot sí puedan ser observables)

% La clase viene acompañada de dos LiveScripts de Matlab para ilustrar los
% ejercicios 8 y 9 del Boletín de problemas 3. Recuerde que los LiveScript
% son editables, por lo que puede probar a cambiar la impedancia de carga.

classdef Smithchart
    properties
        oper
        data
        legend
    end
    methods
        %% General
        function obj = Smithchart()
            obj.oper = [];
            obj.data = [];
            obj.legend = [];
        end

        function obj = blank(obj)
            phi = linspace(0, 2*pi, 1000);
            plot(cos(phi), sin(phi), 'k-','LineWidth',1.5);
        end

        function obj = addoper(obj, oper, data, txt)
            if isempty(obj.oper)
                obj.oper = string(oper);
                obj.data = data;
                if nargin > 3
                    obj.legend = string(txt);
                else
                    obj.legend = " ";
                end
            else
                obj.oper = [obj.oper; string(oper)];
                obj.data = [obj.data; data];
                if nargin > 3
                    obj.legend = [obj.legend; string(txt)];
                else
                    obj.legend = [obj.legend; " "];
                end
            end
        end

        %% Impedance
        function obj = addz(obj, z, txt)
            if nargin > 2
                obj = obj.addoper('Imped', z, txt);
            else
                obj = obj.addoper('Imped', z);
            end
        end
        function obj = plotz(obj, z)
            g = Smithchart.gamma(z);
            plot(real(g), imag(g), '+','LineWidth',3, 'MarkerSize', 15)
        end
        function obj = ploty(obj, z)
            g = Smithchart.gamma(z);
            plot(-real(g), imag(g), '+','LineWidth',3, 'MarkerSize', 15)
        end

        %% Reflection Coefficient
        function obj = addg(obj, g, txt)
            if nargin > 2
                obj = obj.addoper('Gamma', g, txt);
            else
                obj = obj.addoper('Gamma', g);
            end
        end
        function obj = plotg(obj, g)
            plot(real(g), imag(g), 'o','LineWidth',3, 'MarkerSize', 15)
        end
        function obj = plotgy(obj, g)
            plot(-real(g), imag(g), 'o','LineWidth',3, 'MarkerSize', 15)
        end

        %% Inverse Impedance
        function obj = inverseimped(obj)
            if not(isempty(obj.oper))
                index = length(obj.oper);
                switch obj.oper(index)
                    case 'Imped'
                        if obj.legend(index) == " "
                            txt = " ";
                        else
                            txt = "Inverse of " + obj.legend(index);
                        end
                        obj = obj.addoper('Inver', ...
                            Smithchart.inverse(obj.data(index)), ...
                            txt);
                end
            end
        end
        function obj = plotinverseimped(obj, y)
            gy = Smithchart.gamma(y);
            plot(real([-gy gy]), imag([-gy gy]), ':+', ...
                'MarkerIndices', 2,'LineWidth',3, 'MarkerSize', 15)
        end

        %% Imaginary free
        function obj = imagfree(obj)
            if not(isempty(obj.oper))
                index = length(obj.oper);
                switch obj.oper(index)
                    case 'Imped'
                        if obj.legend(index) == " "
                            txt = " ";
                        else
                            txt = "Any Imag of " + obj.legend(index);
                        end
                        obj = obj.addoper('Imagf', ...
                            real(obj.data(index)), ...
                            txt);
                end
            end
        end
        function obj = plotimagfree(obj, r)
            x = [-10.^(2:-0.005:-2) 10.^(-2:0.005:2)];
            g = Smithchart.gamma(r + 1i*x);
            plot(real(g), imag(g), ':','LineWidth',3)
        end
        function obj = plotimagfreey(obj, r)
            x = [-10.^(2:-0.005:-2) 10.^(-2:0.005:2)];
            g = Smithchart.gamma(r + 1i*x);
            plot(-real(g), imag(g), ':','LineWidth',3)
        end

        %% Real free
        function obj = realfree(obj)
            if not(isempty(obj.oper))
                index = length(obj.oper);
                switch obj.oper(index)
                    case 'Imped'
                        if obj.legend(index) == " "
                            txt = " ";
                        else
                            txt = "Any Real of " + obj.legend(index);
                        end
                        obj = obj.addoper('Realf', ...
                            imag(obj.data(index)), ...
                            txt);
                end
            end
        end
        function obj = plotrealfree(obj, x)
            r = 10.^(-2:0.02:2);
            g = Smithchart.gamma(r + 1i*x);
            plot(real(g), imag(g), ':','LineWidth',3)
        end
        function obj = plotrealfreey(obj, x)
            r = 10.^(-2:0.02:2);
            g = Smithchart.gamma(r + 1i*x);
            plot(-real(g), imag(g), ':','LineWidth',3)
        end

        %% Input impedance
        function obj = inputimped(obj)
            if not(isempty(obj.oper))
                index = length(obj.oper);
                switch obj.oper(index)
                    case {'Imped', 'Inver'}
                        if obj.legend(index) == " "
                            txt = " ";
                        else
                            txt = "Line input of " + obj.legend(index);
                        end
                        obj = obj.addoper('Zin', ...
                            obj.data(index), ...
                            txt);
                end
            end
        end
        function obj = plotinputimped(obj, zl)
            theta = linspace(0, 2^pi, 100);
            g = abs(Smithchart.gamma(zl))*exp(1i*theta);
            plot(real(g), imag(g),':' ,'LineWidth',3);
        end

        %% Add Admitance plot
        function obj = addadmit(obj)
            if not(isempty(obj.oper))
                index = length(obj.oper);
                if obj.legend(index) == " "
                    txt = " ";
                else
                    txt = "Inverse plot of " + obj.legend(index);
                end
                obj = obj.addoper('Invpl', ...
                    obj.data(index), ...
                    txt);
            end
        end

        %% Plot all
        function obj = plotall(obj, param)
            figure
            hold on
            if nargin > 1
                switch param
                    case "lines"
                        obj = obj.plotlines;
                end
            end
            obj = obj.blank(); 
            for index = 1:length(obj.oper)
                switch obj.oper(index)
                    case "Imped"
                        obj = obj.plotz(obj.data(index));
                    case "Gamma"
                        obj = obj.plotg(obj.data(index));
                    case "Inver"
                        obj = obj.plotinverseimped(obj.data(index));
                    case "Imagf"
                        obj = obj.plotimagfree(obj.data(index));
                    case "Realf"
                        obj = obj.plotrealfree(obj.data(index));
                    case "Zin"
                        obj = obj.plotinputimped(obj.data(index));
                    case "Invpl"
                        if index>1
                            obj = obj.plotadmit(obj.oper(index-1), ...
                                obj.data(index-1));
                        end
                end
            end
            axis(1.1*[-1 1 -1 1])
            pbaspect([1 1 1])
            h = findobj(gca,'Type','line');
            h = h((length(obj.oper)+1):-1:1);
            legend(h, ["unity circle"; obj.legend], "Location", "northeastoutside")
            hold off
        end

        function obj = plotadmit(obj, oper, data)
            switch oper
                case "Imped"
                    obj = obj.ploty(data);
                case "Gamma"
                    obj = obj.plotgy(data);
                case "Imagf"
                    obj = obj.plotimagfreey(data);
                case "Realf"
                    obj = obj.plotrealfreey(data);
            end
        end

        function obj = plotlines(obj)
            points = [0:0.1:1 1.2:0.2:2 2.5:0.5:5 10 15 20 30 40];
            color = 0.8*[1 1 1];
            width = 0.5;
            for re = points
                x = [-10.^(2:-0.02:-2) 10.^(-2:0.02:2)];
                g = Smithchart.gamma(re + 1i*x);
                plot(real(g), imag(g),'LineWidth', width, 'Color', color)
            end
            for im = points
                r = 10.^(-2:0.02:2);
                g = Smithchart.gamma(r + 1i*im);
                plot(real(g), imag(g),'LineWidth',1, 'Color', color)
                if not(im == 0)
                    plot(real(g), -imag(g),'LineWidth', width, 'Color', color)
                end
            end
        end

    end

    methods (Static)
        function y = inverse(z)
            g = Smithchart.gamma(z);
            y = Smithchart.imped(-g);
        end

        function g = gamma(z)
            if isinf(z)
                g = 1;
            else
                g = (z-1)./(z+1);
            end
        end

        function z = imped(g)
            z = (1+g)./(1-g);
        end

    end
end