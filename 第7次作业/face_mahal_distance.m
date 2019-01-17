clear;
% im1 = imread('./att_faces/s39/1.pgm');
% imshow(im1);
% im1 = reshape(im1, [1,112*92]);

% ��ѵ�����ݴ洢�ھ���train_data�У���240�У�����240��ͼƬ��ÿ�м�ÿ��ͼƬ��ʾ��һ��112*92ά������
train_data = zeros(240,112*92);
att_faces = dir('./att_faces');
count = 1;
for i=4:43
    file = dir(['./att_faces/', att_faces(i).name]);
    for j=[3,5,6,7,8,9]
        temp = imread(['./att_faces/', att_faces(i).name, '/', file(j).name]);
        train_data(count,:) = reshape(temp, [1,112*92]);
        count = count + 1;
    end
end

% ���������ݴ洢�ھ���test_data�У���160�У�����160��ͼƬ��ÿ�м�ÿ��ͼƬ��ʾ��һ��112*92ά������
test_data = zeros(160,112*92);
att_faces = dir('./att_faces');
count = 1;
for i=4:43
    file = dir(['./att_faces/', att_faces(i).name]);
    for j=[10,11,12,4]
        temp = imread(['./att_faces/', att_faces(i).name, '/', file(j).name]);
        test_data(count,:) = reshape(temp, [1,112*92]);
        count = count + 1;
    end
end

% ���ɷַ���
% coeffΪԭ�����Э����������������������ֵ��ѡ����k(=4)������ѡ���Ӧ��k������������
% ͶӰ����Ϊcoeffǰk�С�
% scoreΪ����pcaѹ��������ݡ�
% latentΪ�Ӵ�С���������ֵ��
% explainedΪÿ�����ɷֶ�Ӧ�Ĺ��ױ�����
% muΪԭ����ÿ�еľ�ֵ��ȡ�����Ļ�����֮��muΪ0��
% [coeff,score,latent,tsquared,explained,mu] = pca(train_data, 'Centered', false);
[coeff,score,latent,tsquared,explained,mu] = pca(train_data);

% ͶӰ����
projection_matrix = coeff(:,1:4);
% ����ͶӰ�������pcaѹ����Ľ��
train_data_pca = train_data * projection_matrix;

% ����ѵ���������ͶӰ����;�ֵ���Բ��Լ���ÿһ��ͼ��10304ά�ȣ���ά��4ά�ȡ��õ�160*4����160��ͼ��ĸ�����4��ά�ȡ�
test_data_pca = test_data * projection_matrix;


% ����ʶ����ƥ��
% ���Ͼ���
% ��ÿ��ID��Ϊһ��
train_data_mahal = zeros(6,4,40);
for i=1:40
    train_data_mahal(:,:,i) = train_data_pca((i-1)*6+1:i*6,:);
%     train_data_mahal(:,:,i) = train_data_mahal(:,:,i)';
end
% ����ÿ��ID�ľ�ֵ
mu_mahal = zeros(40,4);
for i=1:40
    mu_mahal(i,:) = mean(train_data_mahal(:,:,i));
end
% �������Ͼ��벢����
mahal_distance = zeros(160,40);
for i = 1:40
    mahal_distance(:,i) = mahal(test_data_pca, train_data_mahal(:,:,i));
end
class_mahal = zeros(1,160);
for i=1:160
    [~,mahal_index] = min(mahal_distance(i,:));
    class_mahal(i) = mahal_index;
end
% ����׼ȷ��
mahal_collect_num = 0;
for i=1:160
    if strcmp(att_faces(class_mahal(i)+3).name, att_faces(ceil(i/4)+3).name)
        mahal_collect_num = mahal_collect_num + 1;
    end
end
mahal_accuracy = mahal_collect_num / 160;
disp(['The accuracy obtained by mahal distance matching method is ', num2str(mahal_accuracy*100), '%']);

% % ���Ͼ���
% % ��ÿ��ID��Ϊһ��
% train_data_mahal = zeros(6,40,40);
% for i=1:40
%     train_data_mahal(:,:,i) = train_data_pca((i-1)*6+1:i*6,:);
% %     train_data_mahal(:,:,i) = train_data_mahal(:,:,i)';
% end
% % ����ÿ��ID�ľ�ֵ
% mu_mahal = zeros(40,40);
% for i=1:40
%     mu_mahal(i,:) = mean(train_data_mahal(:,:,i));
% end
% % ����ÿ��ID��Э�����Լ�Э�������
% cov_mahal = zeros(40,40,40);
% cov_inv_mahal = zeros(40,40,40);
% for i=1:40
% %     cov_mahal(:,:,i) = (1/5) * cov(train_data_mahal(:,:,i));
%     cov_mahal(:,:,i) = (1/5) * (train_data_mahal(:,:,i) - mu_mahal(i,:))' * (train_data_mahal(:,:,i) - mu_mahal(i,:));
% %     cov_inv_mahal(:,:,i) = pinv(cov_mahal(:,:,i));
% end
% I = eye(40);
% for i=1:40
%     cov_mahal(:,:,i) = (cov_mahal(:,:,i)+I)*0.001;
% end
% for i=1:40
%     cov_inv_mahal(:,:,i) = pinv(cov_mahal(:,:,i));
% end
% % �б���
% V = zeros(40,40,160);
% for n=1:160
%     for i=1:40
%         for j = 1:40
%             V(i,j,n) = ((test_data_pca(n,:) - mu_mahal(i,:)) * cov_inv_mahal(:,:,i) * (test_data_pca(n,:) - mu_mahal(i,:))') - ((test_data_pca(n,:) - mu_mahal(j,:)) * cov_inv_mahal(:,:,j) * (test_data_pca(n,:) - mu_mahal(j,:))');
%         end
%     end
% end
% % �����б����������
% class_mahal = zeros(1,160);
% for n = 1:160
%     for j = 1:40
%         if all((V(:,j,n) > 0) == 0)
%             class_mahal(n) = j;
%             break;
%         end
%     end
% end
% % ����׼ȷ��
% mahal_collect_num = 0;
% for i=1:160
%     if strcmp(att_faces(class_mahal(i)+3).name, att_faces(ceil(i/4)+3).name)
%         mahal_collect_num = mahal_collect_num + 1;
%     end
% end
% mahal_accuracy = mahal_collect_num / 160;







