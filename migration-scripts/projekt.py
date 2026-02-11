#!/bin/env python

import json
import os
import sys

from markdownify import markdownify

# read file, json
json_filename = sys.argv[1]

output_filename = 'output-projekt'

if not os.path.exists(output_filename):
    os.makedirs(output_filename)

with open(json_filename, 'r') as json_file:
    data = json.loads(json_file.read())

    # loop over files
    for projekt in data:
        # get slug, open file
        slug = projekt['slug']
        lang = 'sv'

        status = projekt['status']
        if status == 'publish':
            status = 'published'

        person_slug = ''
        person = projekt['acf']['person']
        if person:
            person_slug = person[0]['post_name']

        fname = f"{slug}.md"
        slug_long = f"projekt/{slug}"

        translation = "false" if lang == "sv" else "true"

        with open(fname, "w") as file:
            md = markdownify(projekt['acf']['content'])
            if "<img" in md:
                print(slug)
                continue
            # get md, put in file
            file.write(f"Title: {projekt['title']['rendered']}\n")
            file.write(f"Subtitle: {projekt['acf']['intro']}\n")
            file.write(f"Date: {projekt['date']}\n")
            file.write(f"Modified: {projekt['modified']}\n")
            file.write(f"Slug: {slug_long}\n")
            file.write(f"Status: {status}\n")
            file.write(f"Contact: {person_slug}\n")
            file.write("Authors: \n")
            file.write(f"Lang: {lang}\n")
            file.write(f"Translation: {translation}\n\n")

            # get text, convert to markdown, write
            file.write(md)

