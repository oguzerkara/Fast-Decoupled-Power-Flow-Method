%   MATLAB ver R2018b used
%   This part defines the function. The outputs of this function will be used in a script.
%%
function [Y_matrix, B_type,bus,P_Generated,P_Load,Q_Generated,Q_Load,V] = CDF_IEEEdata

fid=fopen('ieee9cdf.txt'); % openning file

% Use the IEEE 9 bus line data to create the admittance matrix.

tic % timer start
datacomplete= true; % indicator for loop

while(datacomplete) % loop for reading branch and bus datas

lin = fgetl(fid); % reads line
[non,linlength]= size(lin); % takes size of line


if(strcmp(lin(1:3),'BUS')) % looks for bus data start
    while(1) % loops through bus data until "-999" comes
    lin = fgetl(fid); % reads line
    if(strcmp(lin(1:4),'-999'))
      break;  % ends reading bus data
    end
    bus=str2num(lin(1:4)); % converting string to numerical variable
    B_type(bus) = str2num(lin(25:26));% takes bus type: 1:PQ, 2:PV, 3:Vteta(slcak)
    B_conductance = str2num(lin(107:114)); % takes conductance data
    B_admitance =  str2num(lin(115:122)) ; % takes suseptance data
    Y_matrix(bus,bus)= B_conductance +i*B_admitance;  % adds taken data and assigns to Y matrix's nn element
    P_Generated(bus,1) = str2num(lin(60:67)); % takes P generation data
    P_Load(bus,1) = str2num(lin(41:49)); % takes P load data
    Q_Generated(bus,1) = str2num(lin(68:75));% takes Q generation data
    Q_Load(bus,1) = str2num(lin(50:59));% takes Q load data
    V (bus,1)= str2num(lin(28:33)); % takes final voltage data
    end
else if(strcmp(lin(1:6),'BRANCH')) % looks for branch data start
        while (1) % loops through bus data until "-999" comes
            lin= fgetl(fid); % reads line
            if(strcmp(lin(1:4),'-999'))
                datacomplete= false; % boolean is set to close the loop
              break;
            end

                bus_n1=str2num(lin(1:4)); % takes starting bus
                bus_n2=str2num(lin(6:9)); % takes ending bus

                Resistance = (str2num(lin(20:29))); % takes resistance of branch
                Inductance = i*(str2num(lin(30:40))); % takes Inductance value of line
                shunt_admitance=i*(str2num(lin(41:50))); % takes Admitance value of the line

                Y_matrix(bus_n1,bus_n2)= -1*((1/(Inductance + Resistance))); % calculates suseptance and assigns it to y matrix
                Y_matrix(bus_n1,bus_n1)=Y_matrix(bus_n1,bus_n1)+(shunt_admitance/2)-Y_matrix(bus_n1,bus_n2);
                Y_matrix(bus_n2,bus_n1)= -1*((1/(Inductance + Resistance))); % calculates suseptance and assigns it to y matrix but in a reversed manner
                Y_matrix(bus_n2,bus_n2)=Y_matrix(bus_n2,bus_n2)+(shunt_admitance/2)-Y_matrix(bus_n2,bus_n1);
        end

% Detect of all kinds and numbers of buses according to the bus data given by IEEE 9 bus system

    end
  end

end
fclose(fid); % closes file
toc % ends timer
end
