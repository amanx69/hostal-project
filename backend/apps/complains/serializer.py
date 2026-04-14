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
        #! Automatically attach logged-in user
        user = self.context['request'].user
        com = complain.objects.create(user=user, **validated_data)
        return com

    #! update  the complain
    def update(self, instance, validated_data):
        instance.complain_title = validated_data.get('complain_title', instance.complain_title)
        instance.complain_text = validated_data.get('complain_text', instance.complain_text)
        instance.room_number = validated_data.get('room_number', instance.room_number)
        instance.media = validated_data.get('media', instance.media)
        instance.save()
        return instance