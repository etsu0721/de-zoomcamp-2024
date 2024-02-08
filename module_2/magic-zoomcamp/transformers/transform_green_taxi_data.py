from functools import reduce
import re

if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@transformer
def transform(data, *args, **kwargs):
    """
    Template code for a transformer block.

    Add more parameters to this function if this block has multiple parent blocks.
    There should be one parameter for each output variable from each parent block.

    Args:
        data: The output from the upstream parent block
        args: The output from any additional upstream blocks (if applicable)

    Returns:
        Anything (e.g. data frame, dictionary, array, int, str, etc.)
    """
    # Specify your transformation logic here
    data = data[(data['passenger_count'] > 0) & (data['trip_distance'] > 0)]

    data['lpep_pickup_date'] = data['lpep_pickup_datetime'].dt.date

    # Cast camel case column names to snake case
    # accounting for multiple capitalized letters in a row
    data.columns = (
        re.sub(
            '([a-z0-9])([A-Z])', r'\1_\2', 
            re.sub(
                '(.)([A-Z][a-z]+)', r'\1_\2', 
                col
            )
        ).lower()
        for col in data.columns
    )

    return data


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'
    assert output['passenger_count'].isin([0]).sum() == 0, 'There are trips with zero passengers'
    assert output['trip_distance'].isin([0]).sum() == 0, 'There are trips with zero distance'
    assert output['vendor_id'].isin([1, 2]).all() == True, 'There are vendor IDs other than 1 and 2'
