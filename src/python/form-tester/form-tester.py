import requests
from bs4 import BeautifulSoup
import time
import copy
from rich.console import Console
from rich.pretty import pprint

# Set up Console for colored output with 256 colors
console = Console(width=150, color_system="256")

# Define URLs and headers
form_url = "https://dev.opa.ilmatarbrain.com/form-stub/"
ajax_url = "https://dev.opa.ilmatarbrain.com/wp-admin/admin-ajax.php"
headers = {
    'Accept': '*/*',
    'Accept-Language': 'en-GB,en-US;q=0.9,en;q=0.8,de;q=0.7',
    'Connection': 'keep-alive',
    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
    'Origin': 'https://dev.opa.ilmatarbrain.com',
    'Referer': form_url,
    'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1',
    'X-Requested-With': 'XMLHttpRequest'
}

# Base form data template
base_data = {
    'action': 'c_reg_form_submit',
    'first_name': 'Yordan',
    'last_name': 'Georgiev',
    'email': 'unique_email@foobar.com',
    'phone_number': '+358445301465',  # Unique phone number
    'address': 'Läksyrinne 27-29 i e',
    'subscription_plan': 'basic',
}

# Test cases with modified data, expected results, and multiple overrides
test_cases = [
    {"name": "Valid Submission", "data": copy.deepcopy(base_data), 
     "expected": {"status": 200, "success": True}},
    {"name": "Duplicate Email", "data": copy.deepcopy(base_data), 
     "expected": {"status": 200, "success": False, "message": "Tämä s-posti on jo rekisteröity"},
     "overrides": {"phone_number": "+358445301461"}},  # Use a unique phone for email test
    {"name": "Duplicate Phone Number", "data": copy.deepcopy(base_data), 
     "expected": {"status": 200, "success": False, "message": "Tämä puh. nro on jo rekisteröity. Käytä toista puh. nroa!"},
     "overrides": {"email": "unique_email2@foobar.com"}},  # Use a unique email for phone test
    {"name": "Invalid Email Format", "data": copy.deepcopy(base_data), 
     "expected": {"status": 200, "success": False, "message": "Väärä meili muoto"},
     "overrides": {"email": "invalid-email", "phone_number": "+358445301461"}},
    {"name": "Invalid Phone Number Format-has string", "data": copy.deepcopy(base_data), 
     "expected": {"status": 200, "success": False, "message": "Väärä puh. nro muoto"},
     "overrides": {"phone_number": "1s23","email": "valid1@gmail.com"}},
    {"name": "Invalid Phone Number Format-too short", "data": copy.deepcopy(base_data), 
     "expected": {"status": 200, "success": False, "message": "Väärä puh. nro muoto"},
     "overrides": {"phone_number": "123","email": "valid2@gmail.com"}},
     
    {"name": "Missing Required Field - Email", "data": copy.deepcopy(base_data), 
     "expected": {"status": 200, "success": False, "message": "Väärä meili muoto"},
     "overrides": {"email": "", "phone_number": "+358445301462"}},
    {"name": "Missing Required Field - Phone", "data": copy.deepcopy(base_data), 
     "expected": {"status": 200, "success": False, "message": "Väärä puh. nro muoto"},
     "overrides": {"phone_number": "", "email": "valid@gmail.com"}}
]

# Utility functions for colored output
def print_warn(msg: str):
    console.print(f"[yellow]WARN ::: {msg} ::: :warning:[/yellow]")

def print_error(msg: str):
    console.print(f"[bold red]ERROR ::: {msg} ::: :x:[/bold red]")

def print_success(msg: str):
    console.print(f"[green]SUCCESS ::: {msg} ::: :white_check_mark:[/green]")

def print_info(msg: str):
    console.print(f"[cyan]INFO ::: {msg}[/cyan]")

def print_info_heading(heading: str):
    console.rule(f"[bold cyan]{heading}[/bold cyan]")

# Function to retrieve nonce dynamically
def get_nonce():
    response = requests.get(form_url, headers=headers)
    if response.status_code == 200:
        soup = BeautifulSoup(response.text, 'html.parser')
        nonce_field = soup.find('input', {'name': 'c_reg_nonce'})
        if nonce_field:
            return nonce_field.get('value')
    print_warn("Failed to retrieve nonce.")
    return None

# Function to check if test passed or failed
def pass_fail(test_name, expected, actual):
    if actual.get("status") == expected["status"] and actual.get("success") == expected["success"]:
        if "message" in expected and actual.get("message") != expected["message"]:
            print_error(f"{test_name} - TEST FAIL: Expected message '{expected['message']}', got '{actual.get('message')}'")
        else:
            print_success(f"{test_name} - TEST PASS")
    else:
        print_error(f"{test_name} - TEST FAIL: Expected status {expected['status']} and success {expected['success']}, got status {actual.get('status')} and success {actual.get('success')}")

# Test case execution with result validation
def perform_test_case(test_case):
    name, expected = test_case["name"], test_case["expected"]
    # Create a unique copy of data for this test case
    data = copy.deepcopy(test_case["data"])

    # Apply all overrides if specified
    overrides = test_case.get("overrides", {})
    for key, value in overrides.items():
        data[key] = value

    nonce = get_nonce()
    if not nonce:
        print_error(f"Test Case: {name} - Nonce retrieval failed. Skipping test.")
        return

    data['c_reg_nonce'] = nonce
    response = requests.post(ajax_url, headers=headers, data=data)
    print_info_heading(f"Test Case: {name}")
    print_info(f"Status Code: {response.status_code}")

    try:
        response_json = response.json()
        
        # Collect actual response details for validation
        actual = {
            "status": response.status_code,
            "success": response_json.get("success"),
            "message": response_json.get("data", {}).get("message") if isinstance(response_json.get("data"), dict) else response_json.get("data")
        }

        # Display raw JSON response for debugging
        print_info("Raw JSON Response:")
        pprint(response_json)

        # Validate the result
        pass_fail(name, expected, actual)
    
    except ValueError:
        print_error("Failed to parse JSON response.")

# Execute all test cases
for case in test_cases:
    perform_test_case(case)
