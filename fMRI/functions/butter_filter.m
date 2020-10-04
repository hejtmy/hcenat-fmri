function filt_ts = butter_filter(ts, tr, l, h)
fv = 1/tr;
[b,a] = butter(2, [l,h]/(fv/2));
filt_ts = filtfilt(b, a, ts);
