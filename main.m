%fai scrape della pagina
%https://it.wikipedia.org/wiki/Lista_di_numeri_primi 
% metti numeri primi trovati in un array

numn=web_scraping();

%creazioni delle chiavi pubbliche (n,e) a partire da numn, trovando
%phi=(p-1)(q-1) e poi trovando e coprimo a phi
[n,e]=varib_creation(numn);

%prealloco vettore dei tempi di computazione di ogni algoritmo
time=zeros(5,14196);

%prealloco i secondi parametri delle chiavi private che otterrò con gli
%algoritmi di break
d=zeros(1,14196);

%trovo d per ogni chiae pubblica, tenendo traccia dei tempi di computazione
for i=1:size(n)
    [d(i),time(:,i)]=break1(n(i),e(i),numn,i);
end

% t1,t2,t3,t4,t5 sono array di tempi relativi agli algoritmi 1,2,3,4,5
% e composti dai tempi con cui algoritmi ci mettono a rompere la choave prrivat i-esima

%creo la tabella con i relativi tempi, e indici
n_primi_product = n.';
time1=time(1,:);
time2=time(2,:);
time3=time(3,:);
time4=time(4,:);
time5=time(5,:);
index=1:14196;
TT=table(n_primi_product,time1,time2,time3,time4,time5,index);


%grafico gi andamenti dei diversi algoritmi in scala logaritmica di colori
%diversi
colorstring = 'kbgry';
figure
plot((log(TT.time1)),'Color', colorstring(1));
hold on
plot((log(TT.time2)),'Color', colorstring(2));
hold on
plot((log(TT.time3)),'Color', colorstring(3));
hold on
plot((log(TT.time4)),'Color', colorstring(4));
hold on
plot((log(TT.time5)),'Color', colorstring(5));
ylabel('time')
xlabel('index')
hold off


%con una linear regression stimo l'andamento dei miei dati così posso
%confrontarli
figure
plot_linear(TT.time1,TT.index,1);
plot_linear(TT.time2,TT.index,2);
plot_linear(TT.time3,TT.index,3);
plot_linear(TT.time4,TT.index,4);
plot_linear(TT.time5,TT.index,5);
hold off


%%funzioni%%

function numn=web_scraping()
url='https://it.wikipedia.org/wiki/Lista_di_numeri_primi';
html = webread(url);
tree = htmlTree(html);
selector = "ul";
subtrees = findElement(tree,selector);
subtrees(1) = [];
row_content1 = findElement(subtrees(2),"a");
row_content2 = findElement(subtrees(3),"a");
row_content3 = findElement(subtrees(4),"a");

num1 = extractHTMLText(row_content1());
num2 = extractHTMLText(row_content2());
num3 = extractHTMLText(row_content3());

%concateno le 3 diverse sezioni distinte

num=vertcat(num1,num2,num3);

%converto in interi array string

numn=str2double(num);

end


function [n,e]=varib_creation(numn)

%trovo n=p*q facendo prodotti tra il primo elemento di numn e il vettore
%che lo segue, poi elimino i primo elemento e faccio un altro ciclo,
%riducendo a ogni iterazione la dimensione del vettore da moltiplicare
%così facendo evito di fare moltiplicazioni con risultati ridondanti
n1=numn;
n=[];
for j=1:size(numn)
   n=vertcat(n,n1(1)*n1);
   n1(1)=[];
end 


%trovo phi=(p-1)*(q-1) vettore di 168x168 meno i valori che si ripetono
 numn_phi=numn-1;
 phi=[];
for j=1:size(numn_phi)
   phi=vertcat(phi,numn_phi(1)*numn_phi);
   numn_phi(1)=[];
end 



% %genero e trovando un comprimo di phi
% %divido phi per numeri primi numn e quando trova il numero che non è un suo
% %fattore lo assegno a e(i)(sfrutto il fatto che so che elementi numn sono 
% %primi e quindi hanno come divisore solo sè stessi)
e=zeros(14196,1);
for i=1:14196
    for j=1:10 
        if(mod(phi(i),numn(j))~=0)
            e(i)=numn(j); 
            break
        end
    end
end


end


function [d,time] = break1(n,e,numn,i)
 
    tic
    p1=find_divisor1(n);
    time(1)=toc;
    disp(p1);
    
    tic
    p2=find_divisor2(n);
    time(2)=toc;
    disp(p2);
     
    tic
    p3=find_divisor3(n);
    time(3)=toc;
    disp(p3);
    
    tic
    p4=find_divisor4(n,numn);
    time(4)=toc;
      disp(p4);
      
       tic
    p5=find_divisor5(n,numn);
    time(5)=toc;
      disp(p5);

    time=time';
    q=n/p1;
    phi=(p1-1)*(q-1);
    d=find_key(phi,e);
end

%stupido faccio divisione intera per tutti i numeri da 2 a n
function  p=find_divisor1(n) %%black
    p=2;
    for i = 2:n
        if(mod(n,i)==0)
            p=i;
         break;    
        end
    end
end


%vado al massimo fino a radice di ne non a n
function  p=find_divisor2(n)  %Blu
nsq=sqrt(n);
n_lim=ceil(nsq);
p=2;
    for i = 2:n_lim
        if(mod(n,i)==0)
            p=i;
            break;
        end
       
    end
end


%costrusco un vettore arriva fino alla radice di n. ogni volta che faccio
%il resto della divisione intera e non è nulla, elimino dal vettore tutti i
%multipli di quel numero
function  p=find_divisor3(n)%%green

nsq=sqrt(n);
n_lim=ceil(nsq);
num=[2:1:n_lim];
p=2;

    for i = 1:n_lim-1
        if(mod(n,num(i))==0)
            p=num(i);
            break;
        end
        %elimino dal vettore da cui sto testando i divisori (num)tutti
        %multipli dell'elemento che non è divisore
         primo=num(i);
        for j=2:n_lim/i
     
            num(num == (primo*j)) = [];
            
        end
    end
    
end

%uso il vettore di numeri primi usato per costruire n (chiamato numn) per scorrere soltanto i num
%primi 
function  p=find_divisor4(n,numn)%%red
p=2;
    for i = 1:168
        if(mod(n,numn(i)))
            p=i;
            break;
        end
    end
end

%uguale al precedente, ma con il parallel for e quindi senza break
function  p=find_divisor5(n,numn)%%yellow
p=2;
    parfor i = 1:168
        if(mod(n,numn(i)))
            p=i;
            
        end
    end
end


%trovo la chiave privata con l'operazione di mod inversa (al variare di n
%se un multiplo di phi +1 diviso e mi da un numero intero allora ho trovato il d giusto)
function  d=find_key(phi,e)
    n=1;
    d=2.5;
    while(floor(d)~=d)
          d=(n*phi+1)/e;
        n=n+1;
    end
end


function plot_linear(y,x,i)

    index=x.';
    time=y.';
    colorstring = 'kbgry';
    
    X = [ones(height(index),1) index];
    y = time;
    b = X\y; %funzione mldivide
    xlabel('index')
    ylabel('time')
    grid on
    hold on
    y_hat = b(1) + index*b(2);
    plot(index,y_hat,'-r','LineWidth',1,'Color',colorstring(i))


end


%risultano diversi andamenti che mi hanno sorpeso

%il primo algoritmo stupido ha valori temporali molto bassi confrontato 
%agli altri, perchè è semplice, il secondo va meno forte,
%perchè calcola solamente in più il tetto massimo del ciclo. ma
%poi fa lo stesso numero di operazioni del primo perchè c'è il break e
%sicuramente nessuno dei valori che fattorizzo è primo(e quindi deve
%scorrere tutto il vettore non trovando niente)
%il terzo ha una logica complicata e per questo ha valori di tempo alti, anche se
%penso che per numeri molto più grandi di quelli qui trattati, possa essere
%accettabile
%l'algoritmo migliore è il 4, che usa il set di numeri primi già
%precedentemente estratto, per fare solo le divisioni utili
%il peggiore il 5 che è come il precedente, ma
%sfruttando il calcolo parallelo, che impedisce di usare il break, quindi a
%ogni ciclo deve scorrere tutto il vettore. per questo tipo di operazioni
%la parallelizzazione non è efficiente.
