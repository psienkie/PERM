function out = dtmf(x, fs)
    % x - wektor próbek audio
    % fs - częstotliwość próbkowania
    
    dtmf_freqs_rows = [697, 770, 852, 941];
    dtmf_freqs_cols = [1209, 1336, 1477];
    labels = ['1', '2', '3'; '4', '5', '6'; '7', '8', '9'; '*', '0', '#'];
    
    win_len = 512;     % wielkość okna do analizy
    win_overlap = 256; % nakładanie ramek
    nfft = 512;        % liczba próbek do FFT
    
    % Wyznaczenie widma częstotliwości w oknach
    [s, f, t] = spectrogram(x, win_len, win_overlap, nfft, fs);
    A = abs(s) / nfft;
    
    out = "";
    last_pressed_idx = -15; 
    
    for i = 1:length(t)
        frame_spectrum = A(:, i);
        
        [~, index] = maxk(frame_spectrum, 2);
        detected_freqs = f(index(1:2));
        
        [~, row_idx] = min(abs(dtmf_freqs_rows - detected_freqs(1)));
        [~, col_idx] = min(abs(dtmf_freqs_cols - detected_freqs(2)));
        
        if abs(dtmf_freqs_rows(row_idx) - detected_freqs(1)) < 20 && abs(dtmf_freqs_cols(col_idx) - detected_freqs(2)) < 20
            detected_key = labels(row_idx, col_idx);

            if i - last_pressed_idx  >= 15
                out = out + detected_key;
                last_pressed_idx  = i;
            end
        end
    end
end
