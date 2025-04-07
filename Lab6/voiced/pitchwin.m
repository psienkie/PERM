function f0 = pitchwin(x, fs, win)

    num_windows = floor(length(x) / win);
    f_win = zeros(1, num_windows);
    f0 = zeros(1,length(x));

    for i = 1:num_windows
        segment = x((i-1)*win + 1 : i*win); 
        f_max = 300;
        lag_min = fs / f_max;
        
        [c, lags] = xcorr(segment, "normalized");
        c = c(lags > lag_min);
        lags = lags(lags > lag_min);
        [pks, loc] = findpeaks(c, "MinPeakProminence", 0.2, "MinPeakWidth", 3);

        if length(loc) >= 2
            [~, index] = max(pks); 
            f_win(i) =  fs / lags(loc(index));
        end
    end

    for i = 1:num_windows
        start_idx = (i-1) * win + 1;
        end_idx = i * win;
       
        f0(start_idx:end_idx) = f_win(i); 

    end

    

end