#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      LULU
#
# Created:     13-06-2023
# Copyright:   (c) LULU 2023
# Licence:     <your licence>
#-------------------------------------------------------------------------------

import openai


openai.api_key = "API"


def get_top_roles(category):
    query = f"What are the top 20 roles in demand in 2023 in the {category} category?"
    response = openai.Completion.create(
        engine="text-davinci-003",
        prompt=query,
        max_tokens=600,
        n=1,
        stop=None,
        temperature=0.1,
    )
    roles = [choice["text"].strip() for choice in response.choices]
    return roles


def ask_gpt(prompt):
    response = openai.Completion.create(
        engine="text-davinci-003",
        prompt=prompt,
        max_tokens=900,
        n=1,
        stop=None,
        temperature=0.1,
    )
    skills = response.choices[0].text.strip()
    return skills


# Get input for the category
category = input("Enter a category: ")

# Get the top roles for the given category
try:
    roles = get_top_roles(category)
    print(f"Top 20 Roles in Demand in 2023 for {category} Professionals:")
    for i, role in enumerate(roles[:20], 1):
        print(f"{i}. {role[i+1:] if role.startswith(str(i)) else role}")

# Get input for the role
    role = input("Enter your role: ")

# Get the top roles for the given role
    prompt = f"What are the Top 5 Skill Categories, 5 Skills in each Skill Category, Skill Description for each Skill for {role}?"
    skills = ask_gpt(prompt)

    #print(f"\nTop 5 Skill Categories, 5 Skills in each Skill Category, Skill Description for {role}:")

    print(skills)

except Exception:
    print("An error occurred")
