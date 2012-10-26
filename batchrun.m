function batchrun

subjlist = {
    
%'p1_overnight1' - NO OVERNIGHT DATA
'p2_overnight1'
%     'p2_overnight2'
%     'p2_overnight3'
%     'p3_overnight1'
%     'p3_overnight2'
%     'p4_overnight_1bis'
%     'p5_overnight1'
%     'p5_overnight2'
%     'p6_overnight1'
%     'p6_overnight2'
%     'p7_overnight1'
%     'p7_overnight2'
%     'p8_overnight1'
% p9_overnight1 - NO OVERNIGHT DATA
'p10_overnight1'
'p10_overnight2'
% 'p10_overnight3'- CORRUPT DATA
};

sessnum = 1;

for f = 1:length(subjlist)
    subjname = subjlist{f};
    % dataimport_overnight(subjname,1);
    epochdata(sprintf('%s_%d',subjname,sessnum));
end
