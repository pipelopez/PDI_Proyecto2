clear all;
close all;
clc;

%abro la imagen y la guardo en una variable
 imagen = imread('./imagenes/QR2.jpg');
imshow(imagen);%Ahora muestro la imagen.

% %leemos una im�gen que est� distosionada focalmente
% imagen = imread('./imagenes/imagenes_calibracion/Cam0D.jpg');%abro la imagen y la guardo en una variable
% %Creamos un conjunto de entrenamiento con el testigo
% imageFileNames = {'./imagenes/imagenes_calibracion/Cam0.jpg','./imagenes/imagenes_calibracion/Cam1.jpg','./imagenes/imagenes_calibracion/Cam2.jpg', './imagenes/imagenes_calibracion/Cam3.jpg','./imagenes/imagenes_calibracion/Cam4.jpg','./imagenes/imagenes_calibracion/Cam5.jpg','./imagenes/imagenes_calibracion/Cam6.jpg','./imagenes/imagenes_calibracion/Cam7.jpg','./imagenes/imagenes_calibracion/Cam8.jpg','./imagenes/imagenes_calibracion/Cam9.jpg','./imagenes/imagenes_calibracion/Cam10.jpg','./imagenes/imagenes_calibracion/Cam11.jpg','./imagenes/imagenes_calibracion/Cam12.jpg','./imagenes/imagenes_calibracion/Cam13.jpg'};
% 
% 
% % Creamos un arreglo con los puntos detectados en cada una de las im�genes
% % del conjunto de entrenamiento
% [imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints(imageFileNames);
% 
% %Se almacenan los nombres de la im�genes usadas en el vector de im�genes de
% %entrenamiento.
% imageFileNames = imageFileNames(imagesUsed);
% 
% % Generate world coordinates of the corners of the squares
% squareSize = 25;  % indicamos el tama�o de cada cuadr�cula del testigo en mil�metros
% %Se generan las ubicaciones para las esquinas del testigo en cada im�gen de
% %entrenamiento
% worldPoints = generateCheckerboardPoints(boardSize, squareSize);
% 
% % Se calibra la c�mara con los puntos y las esquinas detectadas en el
% % testigo para cada im�gen del conjunto de entrenamiento.
% [cameraParams, imagesUsed, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
%     'EstimateSkew', false, 'EstimateTangentialDistortion', false, ...
%     'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'mm');
% 
% % Se corrige la distorsi�n focal de la im�gen
% J1 = undistortImage(imagen,cameraParams);
% figure;
% imshow(J1);%Ahora muestro la imagen.
% 
% %Se itera hasta que la imagen quede lo mejor posible.
% for i=1:24
%     imagen=J1;
%     J1 = undistortImage(imagen,cameraParams);
% end
% 
% %Se muestra la im�gen.
% figure;imshow(J1);
%     

% Capturo las coordenadas X e Y de 4 puntos seleccionados por el usuario
[X Y] = ginput(4);
% Ordenos los datos en sentido horario de acuerdo a la ubicaci�n de los
% puntos seleccionados por el usuario
[X Y] = ordenarCoordenadasEnSentidoHorario( X, Y );

%Creo dos nuevos vectores columna con los siguientes datos que se usar�n
%como los coeficientes de transformaci�n
x=[1;210;210;1];
y=[1;1;297;297];

% Creo una matriz de ceros en la cual voy a almacenar los nuevos valores de
% la nueva posici�n de los puntos luego realizar las operaciones con los
% coeficientes de transformaci�n, con esto aumentamos la resoluci�n de la
% im�gen.
A=zeros(8,8);
A(1,:)=[X(1),Y(1),1,0,0,0,-1*X(1)*x(1),-1*Y(1)*x(1)];
A(2,:)=[0,0,0,X(1),Y(1),1,-1*X(1)*y(1),-1*Y(1)*y(1)];

A(3,:)=[X(2),Y(2),1,0,0,0,-1*X(2)*x(2),-1*Y(2)*x(2)];
A(4,:)=[0,0,0,X(2),Y(2),1,-1*X(2)*y(2),-1*Y(2)*y(2)];

A(5,:)=[X(3),Y(3),1,0,0,0,-1*X(3)*x(3),-1*Y(3)*x(3)];
A(6,:)=[0,0,0,X(3),Y(3),1,-1*X(3)*y(3),-1*Y(3)*y(3)];

A(7,:)=[X(4),Y(4),1,0,0,0,-1*X(4)*x(4),-1*Y(4)*x(4)];
A(8,:)=[0,0,0,X(4),Y(4),1,-1*X(4)*y(4),-1*Y(4)*y(4)];

%En un vector columna guardamos los datos de los vectores X e Y para cada
%par de coordenadas cartesianas
v=[x(1);y(1);x(2);y(2);x(3);y(3);x(4);y(4)];

%Ahora resolvemos el sistema de ecuaciones para averiguar la relaci�n entre
%las coordenadas de entrada  y las salidas esperadas y lo almacenamos en un vector columna
u=A\v;

%Creamos una nueva matriz que contiene la soluci�n del sistema de ecuaciones
%en una matriz de 3*3 rellenando los espacios faltantes con 1, esta matriz
%ser� nuestra matriz de transformaci�n
U=reshape([u;1],3,3)';

%Escogemos el tipo de forma projective  e ingresamos la matriz de
%transformaci�n U transpuesta para crear nuestra estructura de 
%transformaci�n proyectiva tform
T=maketform('projective',U');

%Hacemos la transformaci�n de la imagen original usando la tform y Xdata y 
%Ydata que son dos vectores de un par de elementos reales que especifican 
%la ubicaci�n espacial de la imagen de salida P2 en el espacio de salida 
%2-D X-Y. Los dos elementos de 'XData' dan las coordenadas X (horizontales)
%de la primera y �ltima columna de P2, respectivamente y los dos elementos 
%de 'YData' dan las coordenadas Y (vertical) de la primera y �ltima filas 
%de P2, respectivamente. Como se puede ver, estos son los coeficientes de
%transformaci�n usados.
P2=imtransform(imagen,T,'XData',[1 210],'YData',[1 297]);

% Mostramos el resultado de la operaci�n
figure,
imshow(P2)