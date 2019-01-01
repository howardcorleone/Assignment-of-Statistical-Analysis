clear;
clc;

image = imread('lena.bmp');

[information1,image_compression1] = compression('lena.bmp', 2);
[information2,image_compression2] = compression('lena.bmp', 4);
[information3,image_compression3] = compression('lena.bmp', 8);

%��ʾͼ��
figure;
subplot(2,2,1);
imshow(image,[]);
title('ԭʼͼ��');
subplot(2,2,2);
imshow(uint8(image_compression1),[]);
title(['ѹ��Ϊ', num2str(1/2), ' ��Ϣ��:', num2str(information1)]);
subplot(2,2,3);
imshow(uint8(image_compression2),[]);
title(['ѹ��Ϊ', num2str(1/4), ' ��Ϣ��:', num2str(information2)]);
subplot(2,2,4);
imshow(uint8(image_compression3),[]);
title(['ѹ��Ϊ', num2str(1/8), ' ��Ϣ��:', num2str(information3)]);
%imwrite(uint8(image_compression), 'lena_compression.bmp');