from django.db import models

# Create your models here.
class Topic(models.Model):
  """A topic the useer wants to record info about"""
  text = models.CharField(max_length=200)
  date_added = models.DateTimeField(auto_now_add=True)

  def __str__(self):
    """Return a string representation of the model."""
    return self.text