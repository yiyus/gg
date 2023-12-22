function []=plotgg(base)
    %% Plot simulation results
    %
    %  eg: plotgg('./gg_')
    %
    %% Crystal and Specimen Symmetries
    % crystal symmetry
    CS = {... 
      'notIndexed',...
      crystalSymmetry('m-3m', [2.9 2.9 2.9], 'mineral', 'Iron-alpha')};
    % plotting convention
    setMTEXpref('xAxisDirection','north');
    setMTEXpref('zAxisDirection','outOfPlane');

    %% File Names
    % which files to be imported
    fname0 = [base '0.ang'];
    fname1 = [base '1.ang'];

    %% Import the Data
    % create EBSD variables containing the data
    ebsd0 = EBSD.load(fname0,CS,'interface','generic',...
      'ColumnNames', { 'phi1' 'Phi' 'phi2' 'x' 'y' 'ConfidenceIndex' 'Phase'}, 'Columns', [1 2 3 4 5 7 8], 'Bunge', 'Radians');
    ebsd1 = EBSD.load(fname1,CS,'interface','generic',...
      'ColumnNames', { 'phi1' 'Phi' 'phi2' 'x' 'y' 'ConfidenceIndex' 'Phase'}, 'Columns', [1 2 3 4 5 7 8], 'Bunge', 'Radians');

    %% Plot
    figure(); plot(ebsd0, ebsd0.orientations)
    figure(); plot(ebsd1, ebsd1.orientations)
end