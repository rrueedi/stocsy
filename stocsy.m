s=csvread('index.csv');
x=csvread('metabolome.csv');
if exist('corrcoef')>0
	t=corrcoef(x);
	o=t(:,s);
elseif exist('corr')>0
for i = 1:size(x,2)
    o(i)=corr(x(:,s),x(:,i));
end
else
o=[];
fprintf(1,'I don''t have a correlation function.');
end
fprintf(1,'I''ve run STOCSY, using index %d',s);
csvwrite('stocsy.csv',o);
