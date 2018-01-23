s=csvread('index.csv');
x=csvread('metabolome.csv');

for i = 1:size(x,2)
    o(i)=corr(x(:,s),x(:,i));
end
fprintf(1,'I''ve run STOCSY.');s
csvwrite('stocsy.csv','o');