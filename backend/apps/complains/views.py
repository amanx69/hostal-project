from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.core.cache import cache

from .models import complain as Complain
from .serializer import ComplainSerializer


from service.response import success_response as _success, error_response as _error


class Createcomplain(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        ser = ComplainSerializer(data=request.data, context={"request": request})
        if ser.is_valid():
            ser.save()
            # Invalidate the complain list cache
            cache.delete("complain_list")
            return _success(
                {"message": "Complaint submitted successfully.", "data": ser.data},
                http_status=status.HTTP_201_CREATED,
            )
        return _error("Complaint submission failed.", errors=ser.errors)

    def get(self, request):
        cache_key = "complain_list"
        cached = cache.get(cache_key)
        if cached:
            return Response(cached, status=status.HTTP_200_OK)

        complains = Complain.objects.all()
        ser = ComplainSerializer(complains, many=True)
        data = {"success": True, "count": complains.count(), "data": ser.data}
        cache.set(cache_key, data, timeout=60)
        return Response(data, status=status.HTTP_200_OK)

    def patch(self, request, id):
        # BUG FIX: original code had `complain = complain.objects.get(id=id)` which shadows
        # the model class name, causing TypeError: 'Complain' object is not callable.
        try:
            instance = Complain.objects.get(id=id)
        except Complain.DoesNotExist:
            return _error("Complaint not found.", http_status=status.HTTP_404_NOT_FOUND)

        ser = ComplainSerializer(instance, data=request.data, partial=True)
        if ser.is_valid():
            ser.save()
            cache.delete("complain_list")
            return _success({"message": "Complaint updated successfully.", "data": ser.data})
        return _error("Complaint update failed.", errors=ser.errors)