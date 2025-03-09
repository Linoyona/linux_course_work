#!/bin/bash

# Define the output file
OUTPUT_FILE="5_output.txt"
CSV_FILE=""
LAST_OUTPUT=""

# Function to log output to file
log_output() {
    echo "$1" | tee -a "$OUTPUT_FILE"
}

# Function to create a CSV file
create_csv() {
    read -p "Enter CSV file name (without extension): " filename
    CSV_FILE="${filename}.csv"
    
    if [ -f "$CSV_FILE" ]; then
        log_output "File $CSV_FILE already exists. Do you want to overwrite it? (y/n)"
        read choice
        if [ "$choice" != "y" ]; then
            log_output "Operation cancelled."
            return
        fi
    fi
    
    # Create CSV with headers
    echo "Date collected,Species,Sex,Weight" > "$CSV_FILE"
    log_output "CSV file $CSV_FILE has been created with headers."
}

# Function to display all CSV data with row index
display_csv() {
    if [ ! -f "$CSV_FILE" ]; then
        log_output "Error: No CSV file selected. Please create or select a CSV file first."
        return
    fi
    
    LAST_OUTPUT=$(awk -F, 'NR==1{print "Index," $0} NR>1{print NR-1 "," $0}' "$CSV_FILE")
    log_output "Displaying CSV data with row index:"
    log_output "$LAST_OUTPUT"
}

# Function to add a new row to the CSV
add_row() {
    if [ ! -f "$CSV_FILE" ]; then
        log_output "Error: No CSV file selected. Please create or select a CSV file first."
        return
    fi
    
    read -p "Enter date collected (MM/DD): " date
    
    # Validate species
    while true; do
        read -p "Enter species (PF, OT, NA): " species
        if [[ "$species" =~ ^(PF|OT|NA)$ ]]; then
            break
        else
            echo "Invalid species. Please enter PF, OT, or NA."
        fi
    done
    
    # Validate sex
    while true; do
        read -p "Enter sex (M/F): " sex
        if [[ "$sex" =~ ^[MF]$ ]]; then
            break
        else
            echo "Invalid sex. Please enter M or F."
        fi
    done
    
    # Validate weight
    while true; do
        read -p "Enter weight (numeric): " weight
        if [[ "$weight" =~ ^[0-9]+$ ]]; then
            break
        else
            echo "Invalid weight. Please enter a numeric value."
        fi
    done
    
    # Add row to CSV
    echo "$date,$species,$sex,$weight" >> "$CSV_FILE"
    log_output "New row added to $CSV_FILE: $date,$species,$sex,$weight"
}

# Function to display all items of a specific species and calculate average weight
display_by_species() {
    if [ ! -f "$CSV_FILE" ]; then
        log_output "Error: No CSV file selected. Please create or select a CSV file first."
        return
    fi
    
    # Validate species
    while true; do
        read -p "Enter species to filter (PF, OT, NA): " species
        if [[ "$species" =~ ^(PF|OT|NA)$ ]]; then
            break
        else
            echo "Invalid species. Please enter PF, OT, or NA."
        fi
    done
    
    # Filter by species and calculate average weight
    LAST_OUTPUT=$(awk -F, -v species="$species" 'BEGIN {sum=0; count=0; print "Items of species " species ":"}
    NR>1 && $2==species {
        print $0; 
        sum+=$4; 
        count++;
    } 
    END {
        if(count>0) 
            print "Average weight of " species ": " sum/count; 
        else 
            print "No items found for species " species;
    }' "$CSV_FILE")
    
    log_output "$LAST_OUTPUT"
}

# Function to display all items of a specific species-sex combination
display_by_species_sex() {
    if [ ! -f "$CSV_FILE" ]; then
        log_output "Error: No CSV file selected. Please create or select a CSV file first."
        return
    fi
    
    # Validate species
    while true; do
        read -p "Enter species to filter (PF, OT, NA): " species
        if [[ "$species" =~ ^(PF|OT|NA)$ ]]; then
            break
        else
            echo "Invalid species. Please enter PF, OT, or NA."
        fi
    done
    
    # Validate sex
    while true; do
        read -p "Enter sex to filter (M/F): " sex
        if [[ "$sex" =~ ^[MF]$ ]]; then
            break
        else
            echo "Invalid sex. Please enter M or F."
        fi
    done
    
    # Filter by species and sex
    LAST_OUTPUT=$(awk -F, -v species="$species" -v sex="$sex" 'BEGIN {print "Items of species " species " with sex " sex ":"}
    NR>1 && $2==species && $3==sex {print $0}
    END {if(NR==1) print "No items found for species " species " with sex " sex;}' "$CSV_FILE")
    
    log_output "$LAST_OUTPUT"
}

# Function to save last output to a new CSV file
save_last_output() {
    if [ -z "$LAST_OUTPUT" ]; then
        log_output "Error: No output to save. Please perform an operation that generates output first."
        return
    fi
    
    read -p "Enter filename to save last output (without extension): " filename
    NEW_CSV="${filename}.csv"
    
    echo "$LAST_OUTPUT" > "$NEW_CSV"
    log_output "Last output saved to $NEW_CSV"
}

# Function to delete a row by index
delete_row() {
    if [ ! -f "$CSV_FILE" ]; then
        log_output "Error: No CSV file selected. Please create or select a CSV file first."
        return
    fi
    
    # Count lines in CSV to validate row index
    line_count=$(wc -l < "$CSV_FILE")
    max_index=$((line_count - 1))
    
    read -p "Enter row index to delete (1-$max_index): " index
    
    # Validate index
    if ! [[ "$index" =~ ^[0-9]+$ ]] || [ "$index" -lt 1 ] || [ "$index" -gt "$max_index" ]; then
        log_output "Error: Invalid row index. Please enter a number between 1 and $max_index."
        return
    fi
    
    # Add 1 to index because of header row
    actual_index=$((index + 1))
    deleted_row=$(sed -n "${actual_index}p" "$CSV_FILE")
    
    # Delete row
    sed -i "${actual_index}d" "$CSV_FILE"
    log_output "Row $index deleted: $deleted_row"
}

# Function to update weight by row index
update_weight() {
    if [ ! -f "$CSV_FILE" ]; then
        log_output "Error: No CSV file selected. Please create or select a CSV file first."
        return
    fi
    
    # Count lines in CSV to validate row index
    line_count=$(wc -l < "$CSV_FILE")
    max_index=$((line_count - 1))
    
    read -p "Enter row index to update weight (1-$max_index): " index
    
    # Validate index
    if ! [[ "$index" =~ ^[0-9]+$ ]] || [ "$index" -lt 1 ] || [ "$index" -gt "$max_index" ]; then
        log_output "Error: Invalid row index. Please enter a number between 1 and $max_index."
        return
    fi
    
    # Validate new weight
    while true; do
        read -p "Enter new weight (numeric): " weight
        if [[ "$weight" =~ ^[0-9]+$ ]]; then
            break
        else
            echo "Invalid weight. Please enter a numeric value."
        fi
    done
    
    # Add 1 to index because of header row
    actual_index=$((index + 1))
    old_row=$(sed -n "${actual_index}p" "$CSV_FILE")
    
    # Update weight by replacing the line
    new_row=$(echo "$old_row" | awk -F, -v weight="$weight" '{$4=weight; print $1 "," $2 "," $3 "," $4}')
    sed -i "${actual_index}s/.*/$new_row/" "$CSV_FILE"
    
    log_output "Weight updated for row $index from $old_row to $new_row"
}

# Main menu function
show_menu() {
    echo ""
    echo "Current CSV file: ${CSV_FILE:-None}"
    echo "====== CSV Management Menu ======"
    echo "1. CREATE CSV by name"
    echo "2. Display all CSV DATA with row INDEX"
    echo "3. Read user input for new row"
    echo "4. Read specie and display all items of that specie type and the AVG weight"
    echo "5. Read Specie sex (M/F) and display all items of specie-sex"
    echo "6. Save last output to new csv file"
    echo "7. Delete row by row index"
    echo "8. Update weight by row index"
    echo "9. Exit"
    echo "================================="
    read -p "Enter your choice (1-9): " choice
    
    case $choice in
        1) create_csv ;;
        2) display_csv ;;
        3) add_row ;;
        4) display_by_species ;;
        5) display_by_species_sex ;;
        6) save_last_output ;;
        7) delete_row ;;
        8) update_weight ;;
        9) log_output "Exiting program. Goodbye!"; exit 0 ;;
        *) log_output "Invalid choice. Please enter a number between 1 and 9." ;;
    esac
}

# Create output file
> "$OUTPUT_FILE"
log_output "==== CSV Management Script Started ===="
log_output "Date: $(date)"

# Main loop
while true; do
    show_menu
done
