#!/bin/bash

# User data for login simulation
declare -A users
users["admin"]="admin"  # Admin login

# Login flag
logged_in=false
current_user=""
total_bill=0
cart=()

# Categories and food items
declare -A food_categories
food_categories=( [1]="Fast Food" [2]="Desserts" [3]="Beverages" )

declare -A food_items
food_items=(
    ["1_1"]="Burger - 150 BDT"
    ["1_2"]="Pizza - 500 BDT"
    ["2_1"]="Ice Cream - 100 BDT"
    ["2_2"]="Cake Slice - 250 BDT"
    ["3_1"]="Soda - 50 BDT"
    ["3_2"]="Coffee - 100 BDT"
)

# Offers
declare -A offers

# Function to handle sign-up
signup() {
    echo -e "\n================= Sign Up ================="
    echo -n "Choose a Username: "
    read new_username
    echo -n "Choose a Password: "
    read -s new_password
    echo ""

    if [[ -z "$new_username" || -z "$new_password" ]]; then
        echo "Username or password cannot be empty. Please try again."
    elif [[ -n "${users[$new_username]}" ]]; then
        echo "Username already exists. Please choose a different username."
    else
        users[$new_username]=$new_password
        echo "Sign-up successful! You can now log in."
    fi
}

# Function to handle login
login() {
    echo -e "\n================= Login ================="
    echo -n "Username: "
    read username
    echo -n "Password: "
    read -s password
    echo ""

    if [[ ${users[$username]} == $password ]]; then
        logged_in=true
        current_user=$username
        echo "Login successful! Welcome, $username."
    else
        echo "Invalid credentials. Please try again."
    fi
}

# Function to display categories and food items
order_food() {
    echo -e "\n============= Food Categories ============="
    for key in "${!food_categories[@]}"; do
        echo "$key. ${food_categories[$key]}"
    done
    echo "=========================================="
    echo -n "Choose a category: "
    read category_choice

    if [[ -n "${food_categories[$category_choice]}" ]]; then
        echo -e "\n============= ${food_categories[$category_choice]} ============="
        for key in "${!food_items[@]}"; do
            if [[ $key == ${category_choice}_* ]]; then
                echo "${key##*_}. ${food_items[$key]}"
            fi
        done
        echo "0. Back to Categories"
        echo "================================================"
        echo -n "Choose an item to order (or add to cart): "
        read item_choice

        if [[ $item_choice -eq 0 ]]; then
            return
        fi

        selected_item="${category_choice}_${item_choice}"

        if [[ -n "${food_items[$selected_item]}" ]]; then
            price=$(echo ${food_items[$selected_item]} | grep -o -E '[0-9]+')
            echo -n "Enter quantity: "
            read quantity
            item_total=$((price * quantity))
            total_bill=$((total_bill + item_total))
            cart+=("${food_items[$selected_item]} x $quantity")
            echo "Added ${food_items[$selected_item]} (x$quantity) to your cart."
        else
            echo "Invalid choice. Please try again."
        fi
    else
        echo "Invalid category. Returning to main menu."
    fi
}

# Function to manage food menu (Admin only)
manage_food_menu() {
    if [[ $current_user != "admin" ]]; then
        echo "Access denied. Only admin can manage food items."
        return
    fi

    echo -e "\n========== Manage Food Menu =========="
    echo "1. Add Category"
    echo "2. Add Food Item"
    echo "3. Update Food Item"
    echo "4. Delete Food Item"
    echo "5. Manage Offers"
    echo "6. Back to Main Menu"
    echo "======================================"
    echo -n "Choose your action: "
    read action

    case $action in
        1) # Add Category
            echo -n "Enter new category name: "
            read new_category
            new_category_id=$(( ${#food_categories[@]} + 1 ))
            food_categories[$new_category_id]="$new_category"
            echo "Category added successfully."
            ;;
        2) # Add Food Item
            echo -n "Enter category ID: "
            read category_id
            if [[ -n "${food_categories[$category_id]}" ]]; then
                echo -n "Enter food item name and price (e.g., Sandwich - 100 BDT): "
                read new_item
                new_key="${category_id}_$((${#food_items[@]} + 1))"
                food_items[$new_key]="$new_item"
                echo "Food item added successfully."
            else
                echo "Invalid category ID."
            fi
            ;;
        3) # Update Food Item
            echo "\nCurrent Food Items:"
            for key in "${!food_items[@]}"; do
                echo "$key. ${food_items[$key]}"
            done
            echo -n "Enter the item ID to update: "
            read update_key
            if [[ -n "${food_items[$update_key]}" ]]; then
                echo -n "Enter the updated food item name and price: "
                read updated_item
                food_items[$update_key]="$updated_item"
                echo "Food item updated successfully."
            else
                echo "Invalid item ID."
            fi
            ;;
        4) # Delete Food Item
            echo "\nCurrent Food Items:"
            for key in "${!food_items[@]}"; do
                echo "$key. ${food_items[$key]}"
            done
            echo -n "Enter the item ID to delete: "
            read delete_key
            if [[ -n "${food_items[$delete_key]}" ]]; then
                unset food_items[$delete_key]
                echo "Food item deleted successfully."
            else
                echo "Invalid item ID."
            fi
            ;;
        5) # Manage Offers
            echo -e "\n========== Manage Offers =========="
            echo "1. Add Offer"
            echo "2. View Offers"
            echo "3. Delete Offer"
            echo "4. Back to Food Menu"
            echo "=================================="
            echo -n "Choose your action: "
            read offer_action

            case $offer_action in
                1) # Add Offer
                    echo -n "Enter offer description: "
                    read new_offer
                    offers[$(( ${#offers[@]} + 1 ))]="$new_offer"
                    echo "Offer added successfully."
                    ;;
                2) # View Offers
                    echo "\nCurrent Offers:"
                    for key in "${!offers[@]}"; do
                        echo "$key. ${offers[$key]}"
                    done
                    ;;
                3) # Delete Offer
                    echo "\nCurrent Offers:"
                    for key in "${!offers[@]}"; do
                        echo "$key. ${offers[$key]}"
                    done
                    echo -n "Enter the offer ID to delete: "
                    read delete_offer_key
                    if [[ -n "${offers[$delete_offer_key]}" ]]; then
                        unset offers[$delete_offer_key]
                        echo "Offer deleted successfully."
                    else
                        echo "Invalid offer ID."
                    fi
                    ;;
                4) return ;;
                *) echo "Invalid choice." ;;
            esac
            ;;
        6) return ;;
        *) echo "Invalid choice." ;;
    esac
}

# Function to play a simple Tic Tac Toe game
play_game() {
    echo "\n Tic Tac Toe game "
}

# Function to view profile
see_profile() {
    echo -e "\n=========== Profile ==========="
    echo "Username: $current_user"
    if [[ $current_user != "admin" ]]; then
        echo "Password: ${users[$current_user]}"
        echo "Total Bill: $total_bill BDT"
        echo "Cart Items:"
        for item in "${cart[@]}"; do
            echo "- $item"
        done
    fi
    echo "==============================="
}

# Main script loop
while true; do
    if [ "$logged_in" = false ]; then
        echo "1. Sign Up"
        echo "2. Log In"
        echo -n "Choose an option: "
        read auth_choice

        case $auth_choice in
            1) signup ;;
            2) login ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
        continue
    fi

    echo -e "\n================= Menu ================="
    echo "1. Order Food"
    echo "2. Track Order"
    echo "3. See Profile"
    echo "4. Play Game to gain coin"
    echo "5. Grocery"
    echo "6. Manage Food Items (Admin)"
    echo "7. Logout"
    echo "8. Exit"
    echo "========================================"
    echo -n "Enter your choice: "
    read choice

    case $choice in
        1) order_food ;;
        2) echo "Tracking feature coming soon..." ;;
        3) see_profile ;;
        4) play_game ;;
        5) echo " feature coming soon..." ;;
        6) manage_food_menu ;;
        7) echo "Logging out..."; logged_in=false; current_user="" ;;
        8) echo "Thank you for using the system. Goodbye!"; break ;;
        *) echo "Invalid choice." ;;
    esac

    echo "\nPress Enter to continue..."
    read
done
