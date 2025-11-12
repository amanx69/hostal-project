from rest_framework import serializers
from .models import complain

class ComplainSerializer(serializers.ModelSerializer):

    user = serializers.StringRelatedField(read_only=True)

    class Meta:
        model = complain
        fields = [
            'id',
            'user',
            'complain_title',
            'complain_text',
            'created_at',
            'status',
            'room_number',
            'media',
        ]

    def create(self, validated_data):
        # Automatically attach logged-in user
        user = self.context['request'].user
        com = complain.objects.create(user=user, **validated_data)
        return com
