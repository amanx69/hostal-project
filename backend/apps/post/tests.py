from django.test import TestCase
from django.contrib.auth import get_user_model
from apps.post.models.post_model import Post
from apps.post.models.comment_model import Comment
from apps.post.models.like_model import Likes
from apps.post.models.FollowingSystem_model import FollowingSystem
from apps.post.serializers.post_Serializer import PostSerializer
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status

User = get_user_model()

class PostModelAndSerializerTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(email="testuser@example.com", password="password123")
        self.post = Post.objects.create(user=self.user, title="My First Post", dec="Hello world!")

    def test_post_creation(self):
        self.assertEqual(Post.objects.count(), 1)
        self.assertEqual(self.post.title, "My First Post")

    def test_post_serializer_validation_success(self):
        data = {
            'title': 'Good Title',
            'dec': 'This is a nice description.'
        }
        serializer = PostSerializer(data=data)
        self.assertTrue(serializer.is_valid())

    def test_post_serializer_validation_missing_content(self):
        data = {
            'title': '',
            'dec': ''
        }
        serializer = PostSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("non_field_errors", serializer.errors)

    def test_post_serializer_profanity_filter(self):
        data = {
            'title': 'Good Title',
            'dec': 'This has bad word: fuck'
        }
        serializer = PostSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("non_field_errors", serializer.errors)
        self.assertTrue("inappropriate language" in str(serializer.errors["non_field_errors"][0]))

class PostAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user1 = User.objects.create_user(email="user1@example.com", password="password123")
        self.user2 = User.objects.create_user(email="user2@example.com", password="password123")
        self.client.force_authenticate(user=self.user1)
        self.post = Post.objects.create(user=self.user2, title="User2 Post", dec="Description")

    def test_create_post_api(self):
        url = reverse('post-viewset-list')
        data = {'title': 'API Post', 'dec': 'API Description'}
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Post.objects.count(), 2)

    def test_toggle_like_api(self):
        url = reverse('toggle_like', kwargs={'post_id': self.post.id})
        # Like the post
        response = self.client.post(url)
        self.assertIn(response.status_code, [status.HTTP_200_OK, status.HTTP_201_CREATED])
        self.assertEqual(Likes.objects.count(), 1)
        # Unlike the post
        response = self.client.post(url)
        self.assertIn(response.status_code, [status.HTTP_200_OK, status.HTTP_204_NO_CONTENT])
        self.assertEqual(Likes.objects.count(), 0)

    def test_comment_on_post_api(self):
        url = reverse('comments_for_post', kwargs={'post_id': self.post.id})
        data = {'text': 'This is a comment'}
        response = self.client.post(url, data)
        self.assertIn(response.status_code, [status.HTTP_200_OK, status.HTTP_201_CREATED])
        self.assertEqual(Comment.objects.count(), 1)

    def test_follow_unfollow_api(self):
        # user1 follows user2
        follow_url = reverse('follow_user', kwargs={'user_id': self.user2.id})
        response = self.client.post(follow_url)
        self.assertIn(response.status_code, [status.HTTP_200_OK, status.HTTP_201_CREATED])
        self.assertEqual(FollowingSystem.objects.count(), 1)

        # user1 unfollows user2
        unfollow_url = reverse('unfollow_user', kwargs={'user_id': self.user2.id})
        response = self.client.delete(unfollow_url)
        self.assertIn(response.status_code, [status.HTTP_200_OK, status.HTTP_204_NO_CONTENT])
        self.assertEqual(FollowingSystem.objects.count(), 0)

    def test_following_and_followers_list_api(self):
        # Follow first
        FollowingSystem.objects.create(follower=self.user1, following=self.user2)

        # Test following list
        following_url = reverse('following_list', kwargs={'user_id': self.user1.id})
        response = self.client.get(following_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data.get('success', True))

        # Test followers list
        followers_url = reverse('followers_list', kwargs={'user_id': self.user2.id})
        response = self.client.get(followers_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data.get('success', True))
