from datetime import datetime
import boto3
from pprint import pprint as pp
import re

def calculate_difference(dt1, dt2):
    minutes_difference = int((dt2 - dt1).total_seconds() / 60)
    if minutes_difference % 15 == 0:
        return minutes_difference
    else:
        remainder = minutes_difference % 15
        if remainder >= 8:
            return minutes_difference + (15 - remainder)
        else:
            return minutes_difference - remainder + 15


def car_entry(conn, plate_number, parking_lot):
    # insert into database
    conn.execute('INSERT INTO tickets (plate_number, parking_lot) VALUES (?, ?)', (plate_number, parking_lot))
    conn.commit()

    # retrieve last inserted row ID
    # row_id = conn.execute('SELECT last_insert_rowid()').fetchone()[0]
    row_id = conn.lastrowid
    conn.close()
    return row_id


def car_exit(conn, ticket_id):
    # query database for ticket with given ID
    cur = conn.cursor()
    cur.execute('SELECT * FROM tickets WHERE id = ?', (ticket_id,))
    row = cur.fetchone()
    if not row:
        return "No Record Found"

    # calculate parked time in hours
    entry_time = datetime.strptime(row[3], '%Y-%m-%d %H:%M:%S')
    exit_time = datetime.now()
    print(entry_time, exit_time)
    parked_time_minutes = calculate_difference(entry_time, exit_time)
    print(f"total time is {parked_time_minutes}. ")

    # calculate price based on parked time
    price = round(parked_time_minutes/15 * 2.5, 2)  # $10 per hour
    conn.close()
    return price




def fetch_number(uploaded_file):
    rekognition_client = boto3.client('rekognition', region_name="us-west-2")
    # Save the file to a temporary directory
    # filename = uploaded_file
    # uploaded_file.save(os.path.join('tmp', filename))
    # uploaded_file = open(os.path.join('tmp', filename), 'rb')

    # Specify the type of recognition required - in this case, we want to detect text in the image
    image_bytes = uploaded_file.read()

    response = rekognition_client.detect_text(Image={'Bytes': image_bytes})

    # Iterate over the detected text to find the number plate number
    number_plate_number = None
    s = ""
    for text in response['TextDetections']:
        pp(text)
        txt = text['DetectedText']
        pp(txt)

        s = ''.join(re.findall(r'\d', txt))
        print(s)
        number_plate_number = None
        if text['Type'] == 'LINE' and re.match(r'^[A-Z]{3}\s\d{4}$', txt):
            number_plate_number = text['DetectedText']
            break

    # os.remove(os.path.join('tmp', filename))
    return number_plate_number
