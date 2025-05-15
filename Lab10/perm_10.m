path = "2/";
imds = imageDatastore(path);
N = numel(imds.Files);

trj = zeros(N, 3);

for k = 1:N
    image = readimage(imds, k);

    image = preprocess(image);
    mask = segment(image);

    [x, y, d] = props(mask);

    trj(k, :) = [x, y, d];

    image = plot(image, trj(1:k, :));
    imshow(image);

    pause(0.1);
end

function out = preprocess(image)
    % Filtr medianowy do usuwania szumu
    out = medfilt3(image);
end

function mask = segment(image)
    % Użycie przygotowanych funkcji do segmentacji
    [initialMask, ~] = createMask(image);
    [finalMask, ~] = segmentImage(image, initialMask);
    mask = finalMask;
end

function [x, y, d] = props(mask)
    % Analiza właściwości obiektu i wybór największego
    [~, stats] = filterRegions(mask);

    if isempty(stats)
        x = NaN;
        y = NaN;
        d = NaN;
        return;
    end

    % Wybieramy region o największym polu
    areas = [stats.Area];
    [~, idx] = max(areas);

    centroid = stats(idx).Centroid;
    diameter = stats(idx).EquivDiameter;

    x = centroid(1);
    y = centroid(2);
    d = diameter/2;
end

function image = plot(image, trj)
    % Wstawianie okręgów jako trajektorii piłki
    for k = 1:size(trj, 1)
        if ~any(isnan(trj(k, :)))
            image = insertShape(image, "circle", trj(k, :), LineWidth=3, Color='red');
        end
    end
end
