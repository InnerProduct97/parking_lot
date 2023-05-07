from django.db import models


class Tickets(models.Model):
    plate = models.CharField(max_length=100)
    parkingLot = models.CharField(max_length=100)
    entry_time = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.plate
