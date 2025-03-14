%% PERM - Lab3
% Piotr Sienkiewicz     324 887
% Tadeusz Chmielik      324 856

function out = dtmf(x, fs)
    % x - wektor próbek audio
    % fs - częstotliwość próbkowania

    % Definicja częstotliwości DTMF
    dtmf_freqs_rows = [697, 770, 852, 941];
    dtmf_freqs_cols = [1209, 1336, 1477];
    labels = ['1', '2', '3'; '4', '5', '6'; '7', '8', '9'; '*', '0', '#'];
    
    % Parametry analizy
    win_len = 512;      % długość okna FFT
    win_overlap = 256;  % nakładanie ramek
    nfft = 1024;        % liczba próbek do FFT
    
    % Obliczenie spektrogramu
    [s, f, t] = spectrogram(x, win_len, win_overlap, nfft, fs);
    A = abs(s);
    
    % Przemapowanie indeksów z STFT na wartości indeksów DTMF
    dtmf_indexes = zeros(1, length(dtmf_freqs_rows) ...
        + length(dtmf_freqs_cols));
    for i = 1:length(dtmf_freqs_rows)
        [~, dtmf_indexes(i)] = min(abs(f - dtmf_freqs_rows(i)));
    end
    for i = 1:length(dtmf_freqs_cols)
        [~, dtmf_indexes(length(dtmf_freqs_rows) + i)] = ...
            min(abs(f - dtmf_freqs_cols(i)));
    end

    % Wyznaczenie poziomu szumu i ile razy sygnał musi przekraczać szum
    global_noise_level = mean(A(:));    
    threshold_factor = 4 * global_noise_level;

    % Wykrywanie klawiszy
    out = "";
    is_signal = false;
    
    for i = 1:length(t)
        % Pobranie amplitud tylko dla częstotliwości DTMF
        dtmf_amplitudes = A(dtmf_indexes, i);
        
        % Sprawdzenie, czy co najmniej 2 częstotliwości mają amplitudy
        % większe niż próg
        strong_freqs = dtmf_amplitudes > threshold_factor;
        if sum(strong_freqs) < 2
            is_signal = false;
            continue;
        end
        
        % Pobranie indeksów dwóch największych częstotliwości i
        % posortowanie
        [~, sorted_idx] = maxk(dtmf_amplitudes, 2);
        detected_freqs = f(dtmf_indexes(sorted_idx));
        detected_freqs = sort(detected_freqs);
        
        % Przemapowanie znalezionych częstotliwości na indeksy DTMF
        [~, row_idx] = min(abs(dtmf_freqs_rows - detected_freqs(1)));
        [~, col_idx] = min(abs(dtmf_freqs_cols - detected_freqs(2)));
        
        % Mapowanie na symbol
        detected_key = labels(row_idx, col_idx);
        
        % Jeżeli wykryto sygnał po ciszy, to dodajemy go
        if ~is_signal
            out = out + detected_key;
            is_signal = true;
        end
    end

end
