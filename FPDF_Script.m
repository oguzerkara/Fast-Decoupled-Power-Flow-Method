
%       This part of the code is the script part. Here the calculations are made.
%%
[Y_matrix, B_type,bus,P_Generated,P_Load,Q_Generated,Q_Load,V] = IEEE_Ymat_Build % returns a Y matrix, B_type, bus as a call to indicate the outputs that will be used
slack_bus =0; load_bus=0;gen_bus=0;unreg_bus=0;
%%
for n=1:bus
         switch B_type(n) % Determining the bus types as data indicates
             case 3
             slack_bus = slack_bus+1;
             display (['Bus ', num2str(n),' is slcak bus'])
             case 1
             load_bus = load_bus+1;
             display (['Bus ', num2str(n),' is load bus'])
             case 2
             gen_bus = gen_bus+1;
             display (['Bus ', num2str(n),' is Generator(PV) bus'])
             case 0
             unreg_bus = unreg_bus+1;
             display (['Bus ', num2str(n),' is Unregulated PQ bus'])
         end
 end
 % The total bus numbers with their identities
 if slack_bus == 0
     fprintf("\n\nno Slack Bus found\n")% There should be always 1 slack bus, so this is an error
 else fprintf("\nNumber of Slack Buses: %d \n",slack_bus)
 end
 if load_bus == 0
     fprintf("no Load Bus found\n")
 else fprintf("Number of Load Buses: %d \n",load_bus)
 end
 if gen_bus == 0
     fprintf("no Generator(PV) Bus found\n")
 else fprintf("Number of Generator(PV) Buses: %d \n",gen_bus)
 end
 if unreg_bus == 0
     fprintf("no Unregulated PQ Bus found\n\n")
 else fprintf("Number of Unregulated PQ Buses: %d \n\n",unreg_bus)
 end
 %% Bus to Bus admittance described below
 for n=1:bus
     for j=1:bus
         if (Y_matrix(n,j)~=0)%for nonzero values
            disp([num2str(n),' to ',num2str(j) ,' = ',num2str((Y_matrix(n,j)))])
         end
     end

 end
 %% B' & B'' matrices are below
         B = imag(Y_matrix);
         Bprime = imag(Y_matrix(slack_bus+1:bus,slack_bus+1:bus)); % Rows&columns: 2(slack_bus+1) to 9(bus)
         Bd_prime = imag(Y_matrix(slack_bus+gen_bus+1:bus,slack_bus+gen_bus+1:bus)); %slack_bus+gen_bus = m => m+1 to bus number

%%
       Pspec = P_Load-P_Generated;
       Qspec = Q_Load-Q_Generated;

%%
    iter = 0;
    error = 1;

% Define error and iteration initial values (1&1) to be used for iteration.

    angle = zeros(bus,1);
% Set all bus voltage magnitudes to 1’s p.u and angles to 0 for flat start.
    G = real(Y_matrix);

    while (error > 0.000001 && iter < 15)
% Start iteration (While (error>0.00001) && (iteration<15))
    P = zeros(bus,1);
    Q = zeros(bus,1);
% Evaluate real and reactive powers using:
      for i = 1:bus
         for j = 1:bus
             P(i) = P(i)+V(j)*(G(i,j)*cos(angle(i)-angle(j))+B(i,j)*sin(angle(i)-angle(j)));
             Q(i) = Q(i)+V(j)*(G(i,j)*sin(angle(i)-angle(j))-B(i,j)*cos(angle(i)-angle(j)));
         end
         if i==2 || i==3 % if gen. bus, tis can be changed by pv bus numbers by changin switch case at top
             if Q(i)<min(Q_Generated)          %As the algorithm leeds, check the boundaries
                   V(j)=V(j)+0.005;
              else
                  if Q(i)>max(Q_Generated)
                      V(j)=V(j)-0.005;
                  end
% Check reactive power limits violations for P-V buses (Generator buses). If violated, increase or decrease voltage magnitude by +/-0.005. (Refer to appendix below).
             end
         end
           delP_over_V(i,1) = P(i)+Pspec(i)/abs(V(i));
           delQ_over_V(i,1) = Q(i)+Qspec(i)/abs(V(i));
      end
      delP_over_V(slack_bus,:) =[];
      delQ_over_V(1:slack_bus+gen_bus,:) = [];
      delTeta = inv(Bprime).*delP_over_V;
      delV = inv(Bd_prime).*delQ_over_V;
% increase the itteration count
       iter = iter+1;
   end
