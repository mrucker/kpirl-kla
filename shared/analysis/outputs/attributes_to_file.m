function f = attributes_to_file(file)

    f = @attributes_to_file_closure;

    function attributes_to_file_closure(description, parameters, attribute_names, attribute_values, ~, ~)

        description_col = repmat({description},size(attribute_values,1),1);
        parameters_col  = repmat({struct2string(parameters)},size(attribute_values,1),1);

        header = [{'description'} attribute_names' {'parameters'}];
        values = [description_col num2cell(attribute_values) parameters_col];

        if ~isfile(file)
            write_header(header, file)
        end

       append_values(values, file);

    end
end

function write_header(header, file)
    format = head_format(size(header,2));
    
    fileID = fopen(file,'w');
    fprintf(fileID,format,header{:});
    fclose(fileID);
end

function append_values(values, file)
    format = value_format(size(values,2));
    
    fileID = fopen(file,'a');

    for row = 1:size(values,1)
        fprintf(fileID, format, values{row,:});
    end
    
    fclose(fileID);
end

function f = head_format(n_headers)
    f = [char(join(repmat("%s",1,n_headers),",")) '\n'];
end

function f = value_format(n_values)
        desc_format  = '"%s"';
        attr_format  = char(join(repmat("%f",1,n_values-2),","));
        param_format = '"%s"';

        f = [ desc_format ',' attr_format ',' param_format '\n'];
end
