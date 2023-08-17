#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      LULU
#
# Created:     17-06-2023
# Copyright:   (c) LULU 2023
# Licence:     <your licence>
#-------------------------------------------------------------------------------

import openai
import requests
import json

# Set up OpenAI API credentials
openai.api_key = 'API'

# Set up Bing Search API credentials
bing_subscription_key = 'API'
bing_endpoint = 'https://api.bing.microsoft.com/v7.0/search'

def chat_gpt(query):
    response = openai.Completion.create(
        engine='text-davinci-003',
        prompt='type the word ' + query + ' in capital letters',
        max_tokens=100,
        n=1,
        stop=None,
        temperature=0.7
    )
    return response.choices[0].text.strip()

def bing_search(query, search_type, count):
    headers = {
        'Ocp-Apim-Subscription-Key': bing_subscription_key
    }
    search_query = f"links for {search_type} on {query}"
    params = {
        'q': search_query,
        'count': count
    }
    response = requests.get(bing_endpoint, headers=headers, params=params)
    search_results = response.json()
    return search_results

def show_results(results, search_type):
    if 'webPages' in results and 'value' in results['webPages']:
        for idx, result in enumerate(results['webPages']['value'], start=1):
            if search_type in result['name'].lower() or search_type in result['url'].lower():
                print(f"Result {idx}:")
                print(f"Title: {result['name']}")
                print(f"URL: {result['url']}")
                print()
        if idx == 0:
            print(f"No {search_type} found for this skill")
    else:
        print(f"No {search_type} found for this skill")

# Example usage
user_query = input("Enter Skill: ")

gpt_output = chat_gpt(user_query)
bing_output_courses = bing_search(gpt_output, 'courses', 10)
bing_output_articles = bing_search(gpt_output, 'articles', 10)
bing_output_masterclasses = bing_search(gpt_output, 'masterclasses', 10)
bing_output_tedtalks = bing_search(gpt_output, 'tedtalks', 5)

print("Top Courses:")
show_results(bing_output_courses, 'courses')

print("\nTop Articles:")
show_results(bing_output_articles, 'articles')

print("\nTop MasterClasses:")
show_results(bing_output_masterclasses, 'masterclasses')

print("\nTop TED Talks:")
show_results(bing_output_tedtalks, 'tedtalks')

