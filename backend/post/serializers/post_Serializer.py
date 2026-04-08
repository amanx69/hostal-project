from  rest_framework import serializers
from post.models import post_model
from .PostUserSerializer import  postUserSerializer
from .comment_Serializer import CommentSerializer
from post.models import like_model, FollowingSystem_model
from post.service.image_compress import process_image 

class PostSerializer(serializers.ModelSerializer):
    post_user= postUserSerializer(source= 'user.user_profile', read_only=True)
    comments= CommentSerializer(many=True, read_only=True)
    author_user_id = serializers.IntegerField(source="user.id", read_only=True)

    likes_count = serializers.SerializerMethodField()
    comments_count = serializers.SerializerMethodField()
    liked_by_me = serializers.SerializerMethodField()
    is_following_author = serializers.SerializerMethodField()

    class Meta:
        model= post_model.Post
        fields= [
            'id',
            'title',
            'dec',
            'media',
            'created_at',
            'updated_at',
            'post_user',
            'author_user_id',
            'comments',
            'likes_count',
            'comments_count',
            'liked_by_me',
            'is_following_author',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at', ]
        
        
 #! content  filter for  title and description
    filter_words=["fuck","bitch","asshole","pussy","dick","bur","land"]
 
    def validate(self, data):
        for data_field in ['title', 'dec']:
            if data.get(data_field):
                for word in self.filter_words:
                    if word in data[data_field].lower():
                        raise serializers.ValidationError(f"The {data_field}  contains {word}  this is inappropriate language.")
        #! compress the image  if  it is  present
        image = data.get('media')
        imagename= getattr(image, 'name', None) #! image name
        print(f"Received image: {imagename}")
       #! image  compression  process
        if image:
            try:
                compressed_image = process_image(image, imagename)
                data['media'] = compressed_image
                print("Image compressed successfully")
            except Exception as e:
                raise serializers.ValidationError(f"Image compression failed: {str(e)}")
        
        if not data.get('title') and not data.get('dec'):
            raise serializers.ValidationError("Either title or description must be provided.")
        return data

    def get_likes_count(self, obj):
        return obj.likes.count()

    def get_comments_count(self, obj):
        return obj.comments.count()

    def _get_request_user(self):
        request = self.context.get("request")
        return getattr(request, "user", None)

    def get_liked_by_me(self, obj):
        user = self._get_request_user()
        if not user or not user.is_authenticated:
            return False
        return like_model.Likes.objects.filter(post=obj, user=user).exists()

    def get_is_following_author(self, obj):
        user = self._get_request_user()
        if not user or not user.is_authenticated:
            return False
        return FollowingSystem_model.FollowingSystem.objects.filter(
            follower=user, following=obj.user
        ).exists()
    
   # compress  the  image  than save it