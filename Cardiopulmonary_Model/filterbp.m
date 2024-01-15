function [ starttimefiltref endtimefiltref] = filterbp( time,flow,airpress,artpress,minvar,maxvar,maxval,minval )

%FILTERING

% filter code
% filter according to the blood pressure signal



%find the data ranges not appropriate from the arterial blood pressure
%curve
lengthwindow = 60; % 40 samples used where the variation needs to be greater than x

timeexcludearraycount =1;

for filterflag = 1 :lengthwindow: (length(artpress)-lengthwindow)
    maxpresswindow=artpress(filterflag);
    minpresswindow=artpress(filterflag);
    for windowflag=filterflag:(filterflag+lengthwindow)
        if artpress(windowflag)<minpresswindow
            minpresswindow=artpress(windowflag);
        end
        if artpress(windowflag)>maxpresswindow
            maxpresswindow=artpress(windowflag);
        end
    end
    if (((maxpresswindow-minpresswindow) <minvar) | ((maxpresswindow-minpresswindow)>maxvar)|(maxpresswindow>maxval) |(minpresswindow<minval))
        %exclude data
        timeexcludestartarray(timeexcludearraycount)= filterflag;
        timeexcludestartarraytime(timeexcludearraycount)= time(filterflag);
        timeexcludeendarray(timeexcludearraycount)= filterflag+lengthwindow;
        timeexcludearraycount= timeexcludearraycount+1;
        
    end
    
end

% At the end of this block we have arrays pointing to the raw data noting
% the timeexcludestart and timeexcludeend of chunks of data



% figure
% plot(time, artpress,'r')
% hold on
% plot(time, artpress,'r.')
% plot(time(timeexcludestartarray),artpress(timeexcludestartarray),'k*')
% plot(time(timeexcludeendarray),artpress(timeexcludeendarray),'b.')




% Remove all subsets of data which do not include more than 100 valid heart
% beats in sucession
% 1 heart beat is about 60 samples, 100 beats 6000 samples

countstarts=1;
for i= 1:(length(timeexcludestartarray)-1)
    if ((timeexcludestartarray(i+1)-timeexcludeendarray(i))>6000) 
        %the period from the end of exclusion to the start of next is good
        %data
        starttimefiltref(countstarts)=timeexcludeendarray(i);
        endtimefiltref(countstarts)= timeexcludestartarray(i+1);
        countstarts=countstarts+1;
    end
end


% figure 
% hold on
% plot(time, artpress,'r.')
% plot(time, artpress,'r')
% plot(time(starttimefiltref), artpress(starttimefiltref),'k*')
% plot(time(endtimefiltref), artpress(endtimefiltref),'b^')

end


