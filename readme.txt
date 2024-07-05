# R Shiny CSV Processor

## Overview
This Shiny application processes a CSV file containing email addresses to find the first purchase details of customers from a MySQL database. The processed data can then be downloaded as a new CSV file.

## Features
- **CSV File Upload**: Users can upload a CSV file containing email addresses.
- **Data Processing**: The app connects to a MySQL database to find relevant customer and order details.
- **Error Handling**: If an error occurs during processing, a message is displayed.
- **Download Processed Data**: Users can download the processed data as a CSV file.

## Libraries Used
- `shiny`
- `shinyjs`
- `RMySQL`
- `tidyverse`
- `lubridate`
- `rio`

## User Interface
- **Title Panel**: "FIRST PURCHASE"
- **File Input**: Allows users to upload a CSV file.
- **Process Button**: Triggers the data processing.
- **Download Button**: Enables downloading of the processed CSV file.
- **Status Message**: Displays the status of the file processing.

## Server Logic
1. **Reactive Value**: `result_f` to store the processing result.
2. **Process Button Event**:
   - Reads the uploaded CSV file.
   - Connects to the MySQL database and retrieves customer and order details.
   - Joins the data and processes it to find the first purchase details.
   - Handles errors and closes the database connection.
3. **Download Button**: Enabled when processing is successful, allows downloading the processed data.
4. **UI Updates**: Updates the UI based on the processing status.

## How to Use
1. **Upload a CSV File**: Click on "Choose CSV file" and upload your CSV file.
2. **Process the File**: Click the "PROCESS" button to start processing the data.
3. **Download the Result**: Once processing is complete, click the "Download Processed CSV" button to download the result.

---