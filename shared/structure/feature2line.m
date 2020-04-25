function line = feature2line(value, size)
    %this isn't ideal for partitioned levels one possible solution is to use a semicircle
    %if this were to work I'd need to show the derivative of distance is a constant just like with the line
    line = value/size;
end