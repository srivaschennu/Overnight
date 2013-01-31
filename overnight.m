function overnight

ts = fix(clock);
datetimestr = sprintf('%02d-%02d-%d %02d-%02d-%02d',ts(3),ts(2),ts(1),ts(4),ts(5),ts(6));
diaryfile = sprintf('diary %s.txt',datetimestr);

diary(diaryfile);

%%%%%%% CONNECT TO NET STATION
nshost = '10.0.0.42';
nsport = 55513;

global nsstatus

if isempty(nsstatus) && ...
        exist('nshost','var') && ~isempty(nshost) && ...
        exist('nsport','var') && nsport ~= 0
    fprintf('Connecting to Net Station.\n');
    [nsstatus, nserror] = NetStation('Connect',nshost,nsport);
    if nsstatus ~= 0
        error('Could not connect to NetStation host %s:%d.\n%s\n', ...
            nshost, nsport, nserror);
    end
end


%%%%%%%% ASSR 1 %%%%%%%%

fprintf('\nIt is now %s\n',datestr(now));
fprintf('Starting ASSR test 1...\n');

cd ../AVSSR/

avssr('param_assr',0);

fprintf('Finished ASSR test 1.\n');
fprintf('\nIt is now %s\n',datestr(now));


%%%%%%%% GLOBAL LOCAL 1 %%%%%%%%

fprintf('\nIt is now %s\n',datestr(now));
fprintf('Starting global-local test 1...\n');

cd ../iGloLoc/

igloloc

fprintf('Finished global-local test 1.\n');
fprintf('\nIt is now %s\n',datestr(now));


%%%%%%%% RESTING STATE 1 %%%%%%%%

resthours = 8;

fprintf('\nIt is now %s\n',datestr(now));
fprintf('Starting overnight recording session 1 for %d hours...\n',resthours);
fprintf('\nPress SPACE to pause or Q to quit at any time.\n');

restingstate(resthours);

fprintf('Stopping overnight recording session 1.\n');
fprintf('\nIt is now %s\n',datestr(now));


%%%%%%%% ASSR 2 %%%%%%%%

fprintf('\nIt is now %s\n',datestr(now));
fprintf('Starting ASSR test 2...\n');

cd ../AVSSR/

avssr('param_assr',0);

fprintf('Finished ASSR test 2.\n');
fprintf('\nIt is now %s\n',datestr(now));


%%%%%%%% GLOBAL LOCAL 2 %%%%%%%%

fprintf('\nIt is now %s\n',datestr(now));
fprintf('Starting global-local test 2...\n');

cd ../iGloLoc/

igloloc

fprintf('Finished global-local test 2.\n');
fprintf('\nIt is now %s\n',datestr(now));


%%%%%%%% RESTING STATE 2 %%%%%%%%

resthours = 4;

fprintf('\nIt is now %s\n',datestr(now));
fprintf('Starting overnight recording session 2 for %d hours...\n',resthours);
fprintf('\nPress SPACE to pause or Q to quit at any time.\n');

restingstate(resthours);

fprintf('Stopping overnight recording session 2.\n');
fprintf('\nIt is now %s\n',datestr(now));

%%%%%%%%%%%%


cd ../Overnight/

fprintf('Done!\n\n');

diary off


function restingstate(resthours)
    
sleeptime = 3600*resthours;

starttime = GetSecs;
stoptime = starttime + sleeptime;
evtime = starttime;

NetStation('Synchronize');
pause(1);

NetStation('StartRecording');
pause(1);

NetStation('Event', 'BGIN');

while GetSecs <= stoptime
    if GetSecs - evtime >= 3600
        fprintf('\nIt is now %s\n',datestr(now));
        evtime = GetSecs;
        NetStation('StopRecording');
        pause(1);
        NetStation('Synchronize');
        pause(1);
        NetStation('StartRecording');
    end
    
    if CharAvail
        keyPressed = GetChar;
        if str2double(sprintf('%d',keyPressed)) == ' '
            NetStation('StopRecording');
            fprintf('\nWaiting... Press SPACE to continue. ');
            while GetChar ~= ' '
            end
            fprintf('Continuing...\n');
            NetStation('Synchronize');
            pause(1);
            NetStation('StartRecording');
            
        elseif strcmpi(keyPressed,'q')
            pause(1);
            NetStation('StopRecording');
            fprintf('\nAborting session.');
            break
        end
        FlushEvents
    end
end

NetStation('Event', 'BEND');
pause(1);
NetStation('StopRecording');