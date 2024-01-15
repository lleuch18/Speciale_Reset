function X=Rnd(x)


X1= 10^round(log(x)/log(10));
X2=  2^round(log(x/X1)/log(2));
X=X1*X2;

end