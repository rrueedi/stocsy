s=csvread('index.csv');
x=csvread('metabolome.csv');

for i = 1:size(x,2)
    o(i)=corr(x(:,s),x(:,i));
end

csvwrite('stocsy.csv','o');