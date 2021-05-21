# Helper that copies a function with the name 'old' into 'new'
function copy_function_ --argument old new
    functions -e "$new"
    functions -c "$old" "$new"
end
