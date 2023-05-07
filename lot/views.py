from django.shortcuts import render, get_object_or_404
from .models import Tickets
from .mixins import *
from django.http import JsonResponse
from django.utils import timezone

def entry(request):
    plate = request.GET.get("plate", None)
    parkingLot = request.GET.get("parkingLot", None)

    if request.method == "POST":
        image = request.FILES.get("image", None)
        plate = fetch_number(image)
        parkingLot = request.POST.get("parkingLot", None)

    ticket = Tickets.objects.create(plate=plate, parkingLot=parkingLot)
    ticket.save()

    return JsonResponse(data={"ticketId": ticket.id}, status=200)


def exit(request):
    ticketId = request.GET.get("ticketId", None)
    if request.method == "POST":
        ticketId = request.POST.get("ticketId", None)

    ticket = get_object_or_404(Tickets, pk=ticketId)

    entry_time = timezone.localtime(ticket.entry_time).replace(tzinfo=None)
    exit_time = datetime.now()
    parked_time_minutes = calculate_difference(entry_time, exit_time)
    price = round(parked_time_minutes / 15 * 2.5, 2)

    return JsonResponse(data={"price": f"{price}$"}, status=200)


def index(request):
    return render(request, "index.html")
