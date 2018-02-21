%  Author: Bao Zhao {zhaobao1988@sjtu.edu.cn}
% this code present the process of generating SDASS descriptor on key
% points, and generating PRC curve.

  load data\Model;
  load data\Scene;


% randomly selecting 1000 key points on scene and model respectively.
L_scene=size(Scene,1);
Scene_key_List=zeros(1000,1);
for i=1:1000
    index=round(rand*L_scene);
    while ~isempty(find(Scene_key_List(1:i)==index, 1))
        index=round(rand*L_scene);
    end
    Scene_key_List(i)=index;
end

Transformation=load('data\Transformation.xf');% the true tranformation from model to scene.
t=Transformation(1:3,end);  
R=Transformation(1:3,1:3);
T_Model=(R*Model')';
T_Model=[T_Model(:,1)+t(1),T_Model(:,2)+t(2),T_Model(:,3)+t(3)];
[Model_key_List,~]=knnsearch(T_Model,Scene(Scene_key_List,:),'k',1);


% obtaining mesh resolution.
[~,d1]=knnsearch(Model,Model,'k',2);
mr=mean(d1(:,2));
Support_radius=20*mr;

% calculating LPA.
Model_indices=1:size(Model,1);  Model_LPAs= LPA(Model, Model_indices, 7*mr);
Scene_indices=1:size(Scene,1);  Scene_LPAs= LPA(Scene, Scene_indices, 7*mr);

% calculating LRA.
Model_LRAs=Improved_LRA( Model, Model_key_List, Support_radius);
Scene_LRAs=Improved_LRA( Scene, Scene_key_List, Support_radius);

% generating SDASS descriptor at key points on model and scene.
projected_radial_size=5;
height_size=5;
deviation_angle_size=15;
Model_Hist=SDASS(Model,Model_key_List,Model_LPAs,Support_radius,projected_radial_size,height_size,deviation_angle_size,Model_LRAs);
Scene_Hist=SDASS(Scene,Scene_key_List,Scene_LPAs,Support_radius,projected_radial_size,height_size,deviation_angle_size,Scene_LRAs);

% generating recall, 1-precision curve.
[Pre,Recall]=generate_RPC(T_Model(Model_key_List,:),Scene(Scene_key_List,:),Model_Hist,Scene_Hist,Support_radius);
%[Pre,Recall]=Compute_p_c_5_15(T_Model(Model_key_List,:),Scene(Scene_key_List,:),Model_Hist,Scene_Hist,Support_radius)


% plot RPC.
figure
plot(Pre,Recall,'-g^','markersize',5)
xlim([0,1])
ylim([0,1])
xlabel('1-Precision')
ylabel('Recall')


