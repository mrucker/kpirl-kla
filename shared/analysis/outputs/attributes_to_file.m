function f = attributes_to_file(file)

    f = @attributes_to_file_closure;

    function attributes_to_file_closure(description, parameters, attribute_names, attribute_values, ~, ~)

        description_col = repmat({description},size(attribute_values,1));
        parameters_col  = repmat({struct2string(parameters)},size(attribute_values,1));

        header = [{'description'} attribute_names {'parameters'}];
        values = [description_col mat2cell(attribute_values) parameters_col];

        if ~isfile(file)
            writecell(file,header);
        end

        desc_format  = '"%s"';
        attr_format  = char(join(repmat("%f",1,size(attribute_values,2)),","));
        param_format = '"%s"'; 

        fileID     = fopen(file,'a');
        formatSpec = [ desc_format ',' attr_format ',' param_format '\n'];

        for row = 1:size(values,1)
            fprintf(fileID,formatSpec,values{row,:});
        end
    end
end