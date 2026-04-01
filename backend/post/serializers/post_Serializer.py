from  rest_framework import serializers
from post.models import post_model
from .PostUserSerializer import  postUserSerializer
from .comment_Serializer import CommentSerializer
from post.service.image_compress import process_image 

class PostSerializer(serializers.ModelSerializer):
    post_user= postUserSerializer(source= 'user',read_only=True)
    comments= CommentSerializer(many=True, read_only=True)
    class Meta:
        model= post_model.Post
        fields= ['id','title','dec','media','created_at','updated_at','post_user','comments']
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
    
   # compress  the  image  than save it