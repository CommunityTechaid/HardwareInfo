#! /usr/bin/zsh

generate_filename () {
    date_string="$(date +%Y-%m-%d)"
    serial_number=$(lshw -class system -json | jq -r '.[0].serial')
    target_filename="$date_string--$serial_number"
    echo "$target_filename"
}

#get_target_filename

target=$(generate_filename)
echo $target

exit